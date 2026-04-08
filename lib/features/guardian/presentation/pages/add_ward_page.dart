import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ward.dart';
import '../providers/guardian_provider.dart';

class AddWardPage extends ConsumerStatefulWidget {
  const AddWardPage({super.key, this.ward});

  /// null이면 추가 모드, non-null이면 수정 모드
  final Ward? ward;

  @override
  ConsumerState<AddWardPage> createState() => _AddWardPageState();
}

class _AddWardPageState extends ConsumerState<AddWardPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  bool get _isEditing => widget.ward != null;

  @override
  void initState() {
    super.initState();
    final w = widget.ward;
    _nameController = TextEditingController(text: w?.name ?? '');
    _ageController = TextEditingController(text: w != null ? '${w.age}' : '');
    _phoneController = TextEditingController(text: w?.phoneNumber ?? '');
    _addressController = TextEditingController(text: w?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final ward = Ward(
      id: _isEditing
          ? widget.ward!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      status: _isEditing ? widget.ward!.status : WardStatus.offline,
      lastUpdated: DateTime.now(),
    );

    if (_isEditing) {
      ref.read(wardsProvider.notifier).updateWard(ward);
    } else {
      ref.read(wardsProvider.notifier).addWard(ward);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? '피보호자 수정' : '피보호자 추가')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '이름 *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '이름을 입력하세요' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: '나이 *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return '나이를 입력하세요';
                final age = int.tryParse(v.trim());
                if (age == null || age <= 0 || age > 150) return '올바른 나이를 입력하세요';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '전화번호 *',
                hintText: '010-0000-0000',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '전화번호를 입력하세요' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '주소 (선택)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: Text(_isEditing ? '저장' : '추가'),
            ),
          ],
        ),
      ),
    );
  }
}
