import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ward.dart';
import '../providers/guardian_provider.dart';

class AddWardPage extends ConsumerStatefulWidget {
  const AddWardPage({super.key});

  @override
  ConsumerState<AddWardPage> createState() => _AddWardPageState();
}

class _AddWardPageState extends ConsumerState<AddWardPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      status: WardStatus.offline,
      lastUpdated: DateTime.now(),
    );

    ref.read(wardsProvider.notifier).addWard(ward);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('피보호자 추가')),
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
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }
}
