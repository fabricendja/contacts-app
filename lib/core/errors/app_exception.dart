import 'package:dio/dio.dart';

/// Erreur métier portant un message affichable à l'utilisateur.
class AppException implements Exception {
  const AppException(this.message);

  factory AppException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const AppException(
          'Le serveur met trop de temps à répondre. Réessayez.',
        );
      case DioExceptionType.connectionError:
        return const AppException(
          'Pas de connexion internet. Vérifiez votre réseau.',
        );
      default:
        return const AppException(
          'Une erreur est survenue lors du chargement des contacts.',
        );
    }
  }

  final String message;

  @override
  String toString() => message;
}
