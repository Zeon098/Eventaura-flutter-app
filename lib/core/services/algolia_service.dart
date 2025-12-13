import 'package:algolia/algolia.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/app_constants.dart';

class AlgoliaService {
  late final Algolia _searchClient;
  late final Algolia _adminClient;

  AlgoliaService() {
    final appId = dotenv.env[AppConstants.algoliaAppIdKey] ?? '';
    final searchKey = dotenv.env[AppConstants.algoliaApiKeyKey] ?? '';
    final adminKey = dotenv.env[AppConstants.algoliaAdminKeyKey] ?? '';

    _searchClient = Algolia.init(applicationId: appId, apiKey: searchKey);

    _adminClient = adminKey.isNotEmpty
        ? Algolia.init(applicationId: appId, apiKey: adminKey)
        : _searchClient;
  }

  AlgoliaIndexReference serviceIndex({bool admin = false}) =>
      (admin ? _adminClient : _searchClient).instance.index('services');
}
