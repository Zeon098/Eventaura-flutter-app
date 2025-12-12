import 'package:algolia/algolia.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/app_constants.dart';

class AlgoliaService {
  late final Algolia _client;

  AlgoliaService() {
    final appId = dotenv.env[AppConstants.algoliaAppIdKey];
    final apiKey = dotenv.env[AppConstants.algoliaApiKeyKey];
    _client = Algolia.init(applicationId: appId ?? '', apiKey: apiKey ?? '');
  }

  AlgoliaIndexReference serviceIndex() => _client.instance.index('services');
}
