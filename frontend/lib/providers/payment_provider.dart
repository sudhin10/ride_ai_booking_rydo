import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../models/transaction_model.dart';
import '../services/card_service.dart';
import '../services/transaction_service.dart';

class PaymentProvider extends ChangeNotifier {
  final _cards = CardService();
  final _txns = TransactionService();

  List<CardModel> cards = [];
  List<TransactionModel> transactions = [];
  bool loading = false;
  String? error;

  CardModel? get defaultCard {
    for (final c in cards) {
      if (c.isDefault) return c;
    }
    return cards.isNotEmpty ? cards.first : null;
  }

  Future<void> loadCards() async {
    loading = true;
    notifyListeners();
    try {
      cards = await _cards.list();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> addCard({
    required String holderName,
    required String number,
    required int expMonth,
    required int expYear,
  }) async {
    try {
      final card = await _cards.add(
          holderName: holderName, number: number, expMonth: expMonth, expYear: expYear);
      cards.insert(0, card);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> setDefault(String id) async {
    await _cards.setDefault(id);
    await loadCards();
  }

  Future<void> removeCard(String id) async {
    await _cards.remove(id);
    cards.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    try {
      transactions = await _txns.list();
      notifyListeners();
    } catch (e) {
      error = e.toString();
    }
  }
}
