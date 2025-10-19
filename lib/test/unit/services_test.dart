import 'package:flutter_test/flutter_test.dart';

import '../../models/user.dart';
import '../../services/storage_service.dart';
import '../../utils/date_formatter.dart';
import '../../utils/status_helper.dart';
import '../../utils/validators.dart';


void main() {
  group('StorageService Tests', () {
    setUp(() async {
      await StorageService.clearAll();
    });

    test('Save and retrieve token', () async {
      const token = 'test_token_123';
      await StorageService.saveToken(token);

      final retrievedToken = await StorageService.getToken();
      expect(retrievedToken, token);
    });

    test('Remove token', () async {
      await StorageService.saveToken('test_token');
      await StorageService.removeToken();

      final retrievedToken = await StorageService.getToken();
      expect(retrievedToken, null);
    });

    test('Save and retrieve user', () async {
      final user = User(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        fullName: 'Test User',
        phoneNumber: '+1234567890',
        role: 'ADMIN',
      );

      await StorageService.saveUser(user);
      final retrievedUser = await StorageService.getUser();

      expect(retrievedUser?.id, user.id);
      expect(retrievedUser?.username, user.username);
      expect(retrievedUser?.email, user.email);
    });

    test('Save and retrieve string', () async {
      await StorageService.saveString('key1', 'value1');
      final value = await StorageService.getString('key1');

      expect(value, 'value1');
    });

    test('ContainsKey returns correct value', () async {
      await StorageService.saveString('key1', 'value1');

      final hasKey = await StorageService.containsKey('key1');
      final noKey = await StorageService.containsKey('key2');

      expect(hasKey, true);
      expect(noKey, false);
    });

    test('ClearAll removes all data', () async {
      await StorageService.saveToken('token');
      await StorageService.saveString('key1', 'value1');

      await StorageService.clearAll();

      final token = await StorageService.getToken();
      final string = await StorageService.getString('key1');

      expect(token, null);
      expect(string, null);
    });
  });

  group('Validators Tests', () {
    test('validateEmail accepts valid email', () {
      expect(Validators.validateEmail('test@example.com'), null);
      expect(Validators.validateEmail('user.name@domain.co.uk'), null);
    });

    test('validateEmail rejects invalid email', () {
      expect(Validators.validateEmail(''), isNot(null));
      expect(Validators.validateEmail('invalid'), isNot(null));
      expect(Validators.validateEmail('test@'), isNot(null));
      expect(Validators.validateEmail('@example.com'), isNot(null));
    });

    test('validatePassword checks length', () {
      expect(Validators.validatePassword(''), isNot(null));
      expect(Validators.validatePassword('short'), isNot(null));
      expect(Validators.validatePassword('validpassword'), null);
      expect(Validators.validatePassword('12345678'), null);
    });

    test('validateUsername checks length', () {
      expect(Validators.validateUsername(''), isNot(null));
      expect(Validators.validateUsername('ab'), isNot(null));
      expect(Validators.validateUsername('abc'), null);
      expect(Validators.validateUsername('validusername'), null);
    });

    test('validateRequired checks for empty values', () {
      expect(Validators.validateRequired('value', 'Field'), null);
      expect(Validators.validateRequired('', 'Field'), isNot(null));
      expect(Validators.validateRequired(null, 'Field'), isNot(null));
    });

    test('validateNumber checks for valid numbers', () {
      expect(Validators.validateNumber('123'), null);
      expect(Validators.validateNumber('12.34'), null);
      expect(Validators.validateNumber('abc'), isNot(null));
      expect(Validators.validateNumber(''), isNot(null));
    });

    test('validatePhone checks phone format', () {
      expect(Validators.validatePhone('+1234567890'), null);
      expect(Validators.validatePhone('1234567890'), null);
      expect(Validators.validatePhone(''), isNot(null));
      expect(Validators.validatePhone('abc'), isNot(null));
    });
  });

  group('DateFormatter Tests', () {
    test('formatDate formats date correctly', () {
      expect(DateFormatter.formatDate('2024-01-15T10:30:00'), '2024-01-15');
      expect(DateFormatter.formatDate('2024-12-31'), '2024-12-31');
    });

    test('formatDate handles invalid input', () {
      expect(DateFormatter.formatDate(''), 'N/A');
      expect(DateFormatter.formatDate(null), 'N/A');
      expect(DateFormatter.formatDate('invalid'), 'invalid');
    });

    test('formatDateTime formats datetime correctly', () {
      final result = DateFormatter.formatDateTime('2024-01-15T10:30:00');
      expect(result, contains('2024-01-15'));
      expect(result, contains('10:30'));
    });

    test('formatRelativeTime shows correct relative time', () {
      final now = DateTime.now();

      // Just now
      final result1 = DateFormatter.formatRelativeTime(now.toIso8601String());
      expect(result1, 'Just now');

      // Hours ago
      final hoursAgo = now.subtract(const Duration(hours: 2));
      final result2 = DateFormatter.formatRelativeTime(hoursAgo.toIso8601String());
      expect(result2, contains('hour'));

      // Days ago
      final daysAgo = now.subtract(const Duration(days: 3));
      final result3 = DateFormatter.formatRelativeTime(daysAgo.toIso8601String());
      expect(result3, contains('day'));
    });
  });

  group('StatusHelper Tests', () {
    test('getOrderStatusColor returns correct colors', () {
      expect(StatusHelper.getOrderStatusColor('PENDING'), isNotNull);
      expect(StatusHelper.getOrderStatusColor('PROCESSING'), isNotNull);
      expect(StatusHelper.getOrderStatusColor('SHIPPED'), isNotNull);
      expect(StatusHelper.getOrderStatusColor('DELIVERED'), isNotNull);
      expect(StatusHelper.getOrderStatusColor('CANCELLED'), isNotNull);
    });

    test('getPrescriptionStatusColor returns correct colors', () {
      expect(StatusHelper.getPrescriptionStatusColor('PENDING'), isNotNull);
      expect(StatusHelper.getPrescriptionStatusColor('APPROVED'), isNotNull);
      expect(StatusHelper.getPrescriptionStatusColor('REJECTED'), isNotNull);
    });

    test('getTicketStatusColor returns correct colors', () {
      expect(StatusHelper.getTicketStatusColor('OPEN'), isNotNull);
      expect(StatusHelper.getTicketStatusColor('IN_PROGRESS'), isNotNull);
      expect(StatusHelper.getTicketStatusColor('RESOLVED'), isNotNull);
      expect(StatusHelper.getTicketStatusColor('CLOSED'), isNotNull);
    });

    test('getPaymentStatusColor returns correct colors', () {
      expect(StatusHelper.getPaymentStatusColor('PENDING'), isNotNull);
      expect(StatusHelper.getPaymentStatusColor('COMPLETED'), isNotNull);
      expect(StatusHelper.getPaymentStatusColor('FAILED'), isNotNull);
      expect(StatusHelper.getPaymentStatusColor('REFUNDED'), isNotNull);
    });

    test('getOrderStatusIcon returns correct icons', () {
      expect(StatusHelper.getOrderStatusIcon('PENDING'), isNotNull);
      expect(StatusHelper.getOrderStatusIcon('PROCESSING'), isNotNull);
      expect(StatusHelper.getOrderStatusIcon('SHIPPED'), isNotNull);
      expect(StatusHelper.getOrderStatusIcon('DELIVERED'), isNotNull);
      expect(StatusHelper.getOrderStatusIcon('CANCELLED'), isNotNull);
    });
  });
}