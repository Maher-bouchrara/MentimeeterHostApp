import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  GraphQLService._();
  static final GraphQLService instance = GraphQLService._();

  late final GraphQLClient client;

  void init() {
    //const url = 'http://10.0.2.2:3001/graphql'; // Android emulator
    const url = 'http://localhost:3001/graphql'; // iOS / web

    final link = HttpLink(url);

    client = GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    );
  }

  // ── Mutations et Queries ─────────────────────────────

  static const String createUserMutation = r'''
    mutation CreateUser(
      $displayName: String!
      $firebaseUid: String
      $role: String
    ) {
      createUser(data: {
        displayName: $displayName
        firebaseUid: $firebaseUid
        role: $role
      }) {
        id
        displayName
        firebaseUid
        role
        createdAt
      }
    }
  ''';

  static const String getUserQuery = r'''
    query GetUser($id: String!) {
      user(id: $id) {
        id
        displayName
        firebaseUid
        role
        createdAt
      }
    }
  ''';

  // ── Methods pour requêtes GraphQL ────────────────────

  /// Crée un user dans PostgreSQL via GraphQL
  /// Retourne l'ID du user crée
  Future<String?> createUser({
    required String displayName,
    required String firebaseUid,
    String role = 'user',
  }) async {
    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(createUserMutation),
          variables: {
            'displayName': displayName,
            'firebaseUid': firebaseUid,
            'role': role,
          },
        ),
      );

      if (result.hasException) {
        print('GraphQL Error: ${result.exception}');
        return null;
      }

      final userId = result.data?['createUser']?['id'] as String?;
      return userId;
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  /// Récupère un user par ID
  Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final result = await client.query(
        QueryOptions(
          document: gql(getUserQuery),
          variables: {'id': userId},
        ),
      );

      if (result.hasException) {
        print('GraphQL Error: ${result.exception}');
        return null;
      }

      final user = result.data?['user'] as Map<String, dynamic>?;
      return user;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }
}
