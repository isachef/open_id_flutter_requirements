import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/blocs/auth_bloc.dart';
import '../features/api/blocs/api_bloc.dart';
import '../features/auth/models/auth_state.dart';
import '../features/api/models/api_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Личный кабинет'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().logout(),
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: theme.colorScheme.primary
                                    .withOpacity(0.2),
                                radius: 30,
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Авторизованный пользователь',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text('Успешный вход через OpenID Connect'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildTokenCard(
                    title: 'Токен доступа',
                    value: state.accessToken,
                    icon: Icons.security,
                    theme: theme,
                  ),
                  _buildTokenCard(
                    title: 'ID Токен',
                    value: state.idToken,
                    icon: Icons.badge,
                    theme: theme,
                  ),
                  _buildTokenCard(
                    title: 'Токен обновления',
                    value: state.refreshToken,
                    icon: Icons.refresh,
                    theme: theme,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.read<ApiBloc>().testApi(),
                          icon: const Icon(Icons.api),
                          label: const Text('Вызвать тестовый API'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed:
                            () => context.read<AuthBloc>().refreshToken(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Обновить токен'),
                      ),
                    ],
                  ),
                  BlocBuilder<ApiBloc, ApiState>(
                    builder: (context, apiState) {
                      if (apiState is ApiLoading) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (apiState is ApiSuccess) {
                        return _buildSimpleApiResultCard(apiState.data, theme);
                      } else if (apiState is ApiError) {
                        return Card(
                          margin: const EdgeInsets.only(top: 16),
                          color: theme.colorScheme.errorContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.error,
                                      color: theme.colorScheme.error,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Ошибка API запроса:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            theme.colorScheme.onErrorContainer,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  apiState.message,
                                  style: TextStyle(
                                    color: theme.colorScheme.onErrorContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ошибка: не авторизован',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Вернуться на экран входа'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimpleApiResultCard(Map<String, dynamic> data, ThemeData theme) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('Результат API запроса:');
    buffer.writeln('-----------------------');

    data.forEach((key, value) {
      if (key == 'data' && value is List) {
        buffer.writeln('$key:');
        _formatTypeValueList(value, buffer, indent: '  ');
      } else if (value is Map) {
        buffer.writeln('$key:');
        _processMap(value, buffer, indent: '  ');
      } else if (value is List) {
        buffer.writeln('$key:');
        _processList(value, buffer, indent: '  ');
      } else {
        buffer.writeln('$key: $value');
      }
    });

    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Результат API запроса',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: Text(
                buffer.toString(),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _formatTypeValueList(
    List list,
    StringBuffer buffer, {
    String indent = '',
  }) {
    for (var item in list) {
      if (item is Map &&
          item.containsKey('type') &&
          item.containsKey('value')) {
        buffer.writeln('$indent- ${item['type']}: ${item['value']}');
      } else if (item is Map) {
        buffer.writeln('$indent- {');
        item.forEach((k, v) => buffer.writeln('$indent    $k: $v'));
        buffer.writeln('$indent  }');
      } else {
        buffer.writeln('$indent- $item');
      }
    }
  }

  void _processMap(Map map, StringBuffer buffer, {String indent = ''}) {
    map.forEach((key, value) {
      if (value is Map) {
        buffer.writeln('$indent$key:');
        _processMap(value, buffer, indent: '$indent  ');
      } else if (value is List) {
        buffer.writeln('$indent$key:');
        _processList(value, buffer, indent: '$indent  ');
      } else {
        buffer.writeln('$indent$key: $value');
      }
    });
  }

  void _processList(List list, StringBuffer buffer, {String indent = ''}) {
    bool isTypeValueFormat =
        list.isNotEmpty &&
        list.every(
          (item) =>
              item is Map &&
              item.containsKey('type') &&
              item.containsKey('value'),
        );

    if (isTypeValueFormat) {
      _formatTypeValueList(list, buffer, indent: indent);
    } else {
      for (int i = 0; i < list.length; i++) {
        var item = list[i];
        if (item is Map) {
          buffer.writeln('$indent- Элемент ${i + 1}:');
          _processMap(item, buffer, indent: '$indent    ');
        } else if (item is List) {
          buffer.writeln('$indent- Элемент ${i + 1}:');
          _processList(item, buffer, indent: '$indent    ');
        } else {
          buffer.writeln('$indent- $item');
        }
      }
    }
  }

  Widget _buildTokenCard({
    required String title,
    required String value,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
