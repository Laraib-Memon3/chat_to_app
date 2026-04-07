import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/workflow/data/datasources/open_router_service.dart';
import 'features/workflow/data/repositories/workflow_repository_impl.dart';
import 'features/workflow/domain/usecases/process_user_prompt.dart';
import 'features/workflow/domain/usecases/update_node_position.dart';
import 'features/workflow/presentation/bloc/workflow_bloc.dart';
import 'features/workflow/presentation/screens/workflow_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationDocumentsDirectory()).path,
          ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ideally, these would be provided via Dependency Injection (like GetIt)
    final dio = Dio();
    // TODO: Replace with your actual OpenRouter API key or use environment variables
    const apiKey =
        ;

    final openRouterService = OpenRouterServiceClient(dio: dio, apiKey: apiKey);
    final workflowRepository = WorkflowRepositoryImpl(
      openRouterService: openRouterService,
    );
    final processUserPrompt = ProcessUserPrompt(workflowRepository);
    final updateNodePosition = UpdateNodePosition();

    return RepositoryProvider.value(
      value: workflowRepository,
      child: BlocProvider(
        create: (context) => WorkflowBloc(
          processUserPrompt: processUserPrompt,
          updateNodePosition: updateNodePosition,
        ),
        child: MaterialApp(
          title: 'Chat-to-Diagram',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const WorkflowScreen(),
        ),
      ),
    );
  }
}
