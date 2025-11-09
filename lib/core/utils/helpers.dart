// lib/core/utils/date_helper.dart

import 'package:intl/intl.dart';

class DateHelper {
  // Format court : 15/11/2024
  static String formatShort(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'fr_FR').format(date);
  }
  
  // Format long : 15 novembre 2024
  static String formatLong(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'fr_FR').format(date);
  }
  
  // Format avec heure : 15/11/2024 à 14:30
  static String formatWithTime(DateTime date) {
    return DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(date);
  }
  
  // Date relative : "Il y a 2 jours"
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return "À l'instant";
        }
        return "Il y a ${difference.inMinutes} min";
      }
      return "Il y a ${difference.inHours}h";
    } else if (difference.inDays == 1) {
      return "Hier";
    } else if (difference.inDays < 7) {
      return "Il y a ${difference.inDays} jours";
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return "Il y a $weeks semaine${weeks > 1 ? 's' : ''}";
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return "Il y a $months mois";
    } else {
      final years = (difference.inDays / 365).floor();
      return "Il y a $years an${years > 1 ? 's' : ''}";
    }
  }
  
  // Nom du jour : "Lundi", "Mardi"...
  static String dayName(DateTime date) {
    return DateFormat('EEEE', 'fr_FR').format(date);
  }
  
  // Nom du mois : "Janvier", "Février"...
  static String monthName(DateTime date) {
    return DateFormat('MMMM', 'fr_FR').format(date);
  }
}