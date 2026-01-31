import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Common country codes with their names
class CountryCode {
  final String code;
  final String name;
  final String flag;

  const CountryCode({
    required this.code,
    required this.name,
    required this.flag,
  });

  @override
  String toString() => '$flag $code';
}

/// List of popular country codes
class CountryCodes {
  static const List<CountryCode> popular = [
    CountryCode(code: '+1', name: 'United States', flag: '🇺🇸'),
    CountryCode(code: '+1', name: 'Canada', flag: '🇨🇦'),
    CountryCode(code: '+44', name: 'United Kingdom', flag: '🇬🇧'),
    CountryCode(code: '+91', name: 'India', flag: '🇮🇳'),
    CountryCode(code: '+86', name: 'China', flag: '🇨🇳'),
    CountryCode(code: '+81', name: 'Japan', flag: '🇯🇵'),
    CountryCode(code: '+49', name: 'Germany', flag: '🇩🇪'),
    CountryCode(code: '+33', name: 'France', flag: '🇫🇷'),
    CountryCode(code: '+39', name: 'Italy', flag: '🇮🇹'),
    CountryCode(code: '+34', name: 'Spain', flag: '🇪🇸'),
    CountryCode(code: '+61', name: 'Australia', flag: '🇦🇺'),
    CountryCode(code: '+55', name: 'Brazil', flag: '🇧🇷'),
    CountryCode(code: '+7', name: 'Russia', flag: '🇷🇺'),
    CountryCode(code: '+82', name: 'South Korea', flag: '🇰🇷'),
    CountryCode(code: '+52', name: 'Mexico', flag: '🇲🇽'),
    CountryCode(code: '+27', name: 'South Africa', flag: '🇿🇦'),
    CountryCode(code: '+971', name: 'UAE', flag: '🇦🇪'),
    CountryCode(code: '+65', name: 'Singapore', flag: '🇸🇬'),
    CountryCode(code: '+60', name: 'Malaysia', flag: '🇲🇾'),
    CountryCode(code: '+63', name: 'Philippines', flag: '🇵🇭'),
  ];
}

/// Phone number input field with country code selector
class PhoneNumberField extends StatelessWidget {
  final String selectedCountryCode;
  final String phoneNumber;
  final ValueChanged<String> onCountryCodeChanged;
  final ValueChanged<String> onPhoneNumberChanged;
  final String? Function(String?)? validator;

  const PhoneNumberField({
    super.key,
    required this.selectedCountryCode,
    required this.phoneNumber,
    required this.onCountryCodeChanged,
    required this.onPhoneNumberChanged,
    this.validator,
  });

  void _showCountryCodePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 400,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Country Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: CountryCodes.popular.length,
                itemBuilder: (context, index) {
                  final country = CountryCodes.popular[index];
                  final isSelected = country.code == selectedCountryCode;
                  
                  return ListTile(
                    leading: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(country.name),
                    trailing: Text(
                      country.code,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Theme.of(context).primaryColor : null,
                      ),
                    ),
                    selected: isSelected,
                    onTap: () {
                      onCountryCodeChanged(country.code);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Find the current country for display
    final currentCountry = CountryCodes.popular.firstWhere(
      (c) => c.code == selectedCountryCode,
      orElse: () => const CountryCode(code: '+1', name: 'United States', flag: '🇺🇸'),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country Code Selector
        InkWell(
          onTap: () => _showCountryCodePicker(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentCountry.flag,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  selectedCountryCode,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Phone Number Field
        Expanded(
          child: TextFormField(
            initialValue: phoneNumber,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter phone number',
              prefixIcon: Icon(Icons.phone),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
            onChanged: onPhoneNumberChanged,
            validator: validator ?? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter phone number';
              }
              if (value.length < 7) {
                return 'Phone number too short';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
