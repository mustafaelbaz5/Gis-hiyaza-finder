import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/excel/holdings_excel_parser.dart';
import '../../data/models/parcel.dart';
import '../../data/repository/holdings_repository.dart';
import '../services/holding_search_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(HomeState.initial());

  final HoldingsRepository _repository;

  Future<void> init() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final List<Parcel>? parcels = await _repository.loadCachedFileIfAny();
      if (parcels == null) {
        emit(state.copyWith(status: HomeStatus.noFile));
        return;
      }
      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          parcels: parcels,
          query: '',
          results: const <SearchResult>[],
        ),
      );
    } on HoldingsParseException catch (e) {
      emit(_parseErrorState(e));
    } catch (_) {
      emit(state.copyWith(status: HomeStatus.noFile));
    }
  }

  Future<void> pickFile() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final List<Parcel> parcels = await _repository.loadFromPickedFile();
      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          parcels: parcels,
          query: '',
          results: const <SearchResult>[],
        ),
      );
    } on HoldingsFilePickCancelled {
      // User dismissed the picker — return to whatever state we were in.
      emit(
        state.copyWith(
          status: state.parcels.isEmpty
              ? HomeStatus.noFile
              : HomeStatus.loaded,
        ),
      );
    } on HoldingsParseException catch (e) {
      emit(_parseErrorState(e));
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Same as [pickFile] — kept as a distinct, semantically named entry
  /// point for the "change file" action in the UI.
  Future<void> changeFile() => pickFile();

  void search(final String query) {
    final List<SearchResult> results = query.trim().isEmpty
        ? const <SearchResult>[]
        : _repository.search(query);
    emit(state.copyWith(query: query, results: results));
  }

  HomeState _parseErrorState(final HoldingsParseException e) {
    return state.copyWith(
      status: HomeStatus.error,
      errorMessage: e.toString(),
      missingColumns: e.missingColumns,
    );
  }
}
