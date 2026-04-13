import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GuardianRegisterPage extends StatefulWidget {
  const GuardianRegisterPage({super.key});

  @override
  State<GuardianRegisterPage> createState() => _GuardianRegisterPageState();
}

class _GuardianRegisterPageState extends State<GuardianRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationController = TextEditingController();

  bool _isPrimary = false;
  String? _selectedRelation;

  static const _relations = ['배우자', '자녀', '부모', '형제/자매', '친척', '지인', '기타'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: 보호자 등록 API 연동
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('보호자가 등록되었습니다.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '보호자 등록',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 기본 정보
                _SectionLabel('기본 정보'),
                const SizedBox(height: 8),
                _FormCard(
                  children: [
                    _FormField(
                      label: '이름',
                      controller: _nameController,
                      hintText: '보호자 이름',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? '이름을 입력해주세요.' : null,
                    ),
                    _Divider(),
                    _FormField(
                      label: '연락처',
                      controller: _phoneController,
                      hintText: '010-0000-0000',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _PhoneNumberFormatter(),
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return '연락처를 입력해주세요.';
                        final digits = v.replaceAll('-', '');
                        if (digits.length < 10) return '올바른 연락처를 입력해주세요.';
                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 관계 설정
                _SectionLabel('관계'),
                const SizedBox(height: 8),
                _FormCard(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: DropdownButtonFormField<String>(
                        value: _selectedRelation,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelText: '관계 선택',
                          labelStyle: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        items: _relations
                            .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 14))))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedRelation = v),
                        validator: (v) => v == null ? '관계를 선택해주세요.' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 권한 설정
                _SectionLabel('권한 설정'),
                const SizedBox(height: 8),
                _FormCard(
                  children: [
                    _SwitchRow(
                      label: '주 보호자로 설정',
                      subLabel: '긴급 상황 시 최우선 연락',
                      value: _isPrimary,
                      onChanged: (v) => setState(() => _isPrimary = v),
                    ),
                    _Divider(),
                    _InfoRow(icon: Icons.notifications_outlined, label: '이상 신호 알림 수신'),
                    _Divider(),
                    _InfoRow(icon: Icons.favorite_border, label: '생체 데이터 열람'),
                    _Divider(),
                    _InfoRow(icon: Icons.directions_run, label: '활동상태 열람'),
                  ],
                ),

                const SizedBox(height: 20),

                // 초대 안내
                _SectionLabel('초대 방법'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StepItem(step: '1', text: '보호자의 연락처를 입력하고 등록합니다.'),
                      SizedBox(height: 8),
                      _StepItem(step: '2', text: '보호자에게 초대 문자가 발송됩니다.'),
                      SizedBox(height: 8),
                      _StepItem(step: '3', text: '보호자가 앱에서 수락하면 연동이 완료됩니다.'),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 등록 버튼
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '보호자 등록하기',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 공용 위젯 ──────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(children: children),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFEEEEEE));
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final String subLabel;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.label,
    required this.subLabel,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
              Text(subLabel, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.black,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          const Spacer(),
          const Icon(Icons.check, size: 16, color: Colors.black38),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String step;
  final String text;
  const _StepItem({required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFE0E0E0),
            shape: BoxShape.circle,
          ),
          child: Text(step, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ),
      ],
    );
  }
}

// ── 전화번호 포매터 ────────────────────────────────────

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll('-', '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 7) buffer.write('-');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
