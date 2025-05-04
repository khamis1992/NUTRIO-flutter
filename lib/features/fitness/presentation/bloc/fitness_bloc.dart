import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrio_wellness/core/services/service_locator.dart';
import 'package:nutrio_wellness/features/fitness/data/models/fitness_data_model.dart';
import 'package:nutrio_wellness/features/fitness/data/repositories/fitness_repository.dart';

// Events
abstract class FitnessEvent extends Equatable {
  const FitnessEvent();

  @override
  List<Object?> get props => [];
}

class LoadDailySummary extends FitnessEvent {
  final DateTime date;

  const LoadDailySummary(this.date);

  @override
  List<Object?> get props => [date];
}

class LoadWeeklySummary extends FitnessEvent {
  final DateTime startDate;

  const LoadWeeklySummary(this.startDate);

  @override
  List<Object?> get props => [startDate];
}

class LoadFitnessData extends FitnessEvent {
  final DateTime startDate;
  final DateTime endDate;
  final FitnessDataType? type;

  const LoadFitnessData({
    required this.startDate,
    required this.endDate,
    this.type,
  });

  @override
  List<Object?> get props => [startDate, endDate, type];
}

class SyncFitnessData extends FitnessEvent {
  final String provider;

  const SyncFitnessData(this.provider);

  @override
  List<Object?> get props => [provider];
}

class AddManualFitnessData extends FitnessEvent {
  final FitnessDataModel data;

  const AddManualFitnessData(this.data);

  @override
  List<Object?> get props => [data];
}

class LoadWorkoutSessions extends FitnessEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadWorkoutSessions({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class AddWorkoutSession extends FitnessEvent {
  final WorkoutSession session;

  const AddWorkoutSession(this.session);

  @override
  List<Object?> get props => [session];
}

// States
abstract class FitnessState extends Equatable {
  const FitnessState();

  @override
  List<Object?> get props => [];
}

class FitnessInitial extends FitnessState {}

class FitnessLoading extends FitnessState {}

class FitnessError extends FitnessState {
  final String message;

  const FitnessError(this.message);

  @override
  List<Object?> get props => [message];
}

class DailySummaryLoaded extends FitnessState {
  final DailyFitnessSummary summary;

  const DailySummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class WeeklySummaryLoaded extends FitnessState {
  final List<DailyFitnessSummary> summaries;

  const WeeklySummaryLoaded(this.summaries);

  @override
  List<Object?> get props => [summaries];
}

class FitnessDataLoaded extends FitnessState {
  final List<FitnessDataModel> data;

  const FitnessDataLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class FitnessDataSyncing extends FitnessState {
  final String provider;

  const FitnessDataSyncing(this.provider);

  @override
  List<Object?> get props => [provider];
}

class FitnessDataSynced extends FitnessState {
  final String provider;

  const FitnessDataSynced(this.provider);

  @override
  List<Object?> get props => [provider];
}

class WorkoutSessionsLoaded extends FitnessState {
  final List<WorkoutSession> sessions;

  const WorkoutSessionsLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class WorkoutSessionAdded extends FitnessState {
  final WorkoutSession session;

  const WorkoutSessionAdded(this.session);

  @override
  List<Object?> get props => [session];
}

// Bloc
class FitnessBloc extends Bloc<FitnessEvent, FitnessState> {
  final FitnessRepository _fitnessRepository = getIt<FitnessRepository>();

  FitnessBloc() : super(FitnessInitial()) {
    on<LoadDailySummary>(_onLoadDailySummary);
    on<LoadWeeklySummary>(_onLoadWeeklySummary);
    on<LoadFitnessData>(_onLoadFitnessData);
    on<SyncFitnessData>(_onSyncFitnessData);
    on<AddManualFitnessData>(_onAddManualFitnessData);
    on<LoadWorkoutSessions>(_onLoadWorkoutSessions);
    on<AddWorkoutSession>(_onAddWorkoutSession);
  }

  Future<void> _onLoadDailySummary(
    LoadDailySummary event,
    Emitter<FitnessState> emit,
  ) async {
    emit(FitnessLoading());
    try {
      final summary = await _fitnessRepository.getDailySummary(event.date);
      emit(DailySummaryLoaded(summary));
    } catch (e) {
      emit(FitnessError(e.toString()));
    }
  }

  Future<void> _onLoadWeeklySummary(
    LoadWeeklySummary event,
    Emitter<FitnessState> emit,
  ) async {
    emit(FitnessLoading());
    try {
      final summaries = await _fitnessRepository.getWeeklySummary(event.startDate);
      emit(WeeklySummaryLoaded(summaries));
    } catch (e) {
      emit(FitnessError(e.toString()));
    }
  }

  Future<void> _onLoadFitnessData(
    LoadFitnessData event,
    Emitter<FitnessState> emit,
  ) async {
    emit(FitnessLoading());
    try {
      final data = await _fitnessRepository.getFitnessData(
        startDate: event.startDate,
        endDate: event.endDate,
        type: event.type,
      );
      emit(FitnessDataLoaded(data));
    } catch (e) {
      emit(FitnessError(e.toString()));
    }
  }

  Future<void> _onSyncFitnessData(
    SyncFitnessData event,
    Emitter<FitnessState> emit,
  ) async {
    emit(FitnessDataSyncing(event.provider));
    try {
      await _fitnessRepository.syncFitnessData(event.provider);
      emit(FitnessDataSynced(event.provider));
    } catch (e) {
      emit(FitnessError(e.toString()));
    }
  }

  Future<void> _onAddManualFitnessData(
    AddManualFitnessData event,
    Emitter<FitnessState> emit,
  ) async {
    emit(FitnessLoading());
    try {
      await _fitnessRepository.addManualFitnessData(event.data);
      
      // Refresh the daily summary
      final summary = await _fitnessRepository.getDailySummary(event.data.timestamp);
      emit(DailySummaryLoaded(summary));
    } catch (e) {
      emit(FitnessError(e.toString()));
    }
  }

  Future<void> _onLoadWorkoutSessions(
    LoadWorkoutSessions event,
    Emitter<FitnessState> emit,
  ) async {
    emit(FitnessLoading());
    try {
      final sessions = await _fitnessRepository.getWorkoutSessions(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(WorkoutSessionsLoaded(sessions));
    } catch (e) {
      emit(FitnessError(e.toString()));
    }
  }

  Future<void> _onAddWorkoutSession(
    AddWorkoutSession event,
    Emitter<FitnessState> emit,
  ) async {
    emit(FitnessLoading());
    try {
      await _fitnessRepository.addWorkoutSession(event.session);
      emit(WorkoutSessionAdded(event.session));
      
      // Refresh workout sessions
      final startDate = DateTime.now().subtract(const Duration(days: 30));
      final endDate = DateTime.now();
      final sessions = await _fitnessRepository.getWorkoutSessions(
        startDate: startDate,
        endDate: endDate,
      );
      emit(WorkoutSessionsLoaded(sessions));
    } catch (e) {
      emit(FitnessError(e.toString()));
    }
  }
}
