import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/excel/holdings_excel_parser.dart';
import '../../data/models/cached_file_entry.dart';
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
      emit(_loadedState(parcels));
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
      emit(_loadedState(parcels));
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

  /// Switches the active dataset to a previously-loaded file from history.
  Future<void> openHistoryEntry(final CachedFileEntry entry) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final List<Parcel> parcels = await _repository.loadFromHistoryEntry(
        entry,
      );
      emit(_loadedState(parcels));
    } on HoldingsFilePickCancelled {
      emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: 'الملف لم يعد موجودًا على الجهاز.',
        ),
      );
    } on HoldingsParseException catch (e) {
      emit(_parseErrorState(e));
    } catch (e) {
      emit(
        state.copyWith(status: HomeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  HomeState _loadedState(final List<Parcel> parcels) {
    return state.copyWith(
      status: HomeStatus.loaded,
      parcels: parcels,
      query: '',
      results: const <SearchResult>[],
      availableBasins: _repository.availableBasins,
      selectedBasin: null,
    );
  }

  void search(final String query) {
    final List<SearchResult> results = query.trim().isEmpty
        ? const <SearchResult>[]
        : _repository.search(query, basin: state.selectedBasin);
    emit(state.copyWith(query: query, results: results));
  }

  /// Narrows subsequent searches to [basin] (اسم الحوض), or `null` to
  /// search the whole loaded dataset again.
  void selectBasin(final String? basin) {
    final List<SearchResult> results = state.query.trim().isEmpty
        ? const <SearchResult>[]
        : _repository.search(state.query, basin: basin);
    emit(state.copyWith(selectedBasin: basin, results: results));
  }

  HomeState _parseErrorState(final HoldingsParseException e) {
    return state.copyWith(
      status: HomeStatus.error,
      errorMessage: e.toString(),
      missingColumns: e.missingColumns,
    );
  }
}
