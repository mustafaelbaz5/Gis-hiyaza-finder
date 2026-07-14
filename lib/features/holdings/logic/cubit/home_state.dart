import 'package:equatable/equatable.dart';

import '../../data/models/parcel.dart';
import '../services/holding_search_service.dart';

enum HomeStatus { loading, noFile, loaded, error }

class HomeState extends Equatable {
  const HomeState({
    required this.status,
    this.parcels = const <Parcel>[],
    this.query = '',
    this.results = const <SearchResult>[],
    this.errorMessage,
    this.missingColumns = const <String>[],
  });

  factory HomeState.initial() => const HomeState(status: HomeStatus.loading);

  final HomeStatus status;
  final List<Parcel> parcels;
  final String query;
  final List<SearchResult> results;
  final String? errorMessage;
  final List<String> missingColumns;

  int get holdingCount =>
      parcels.map((final Parcel p) => p.holdingId).toSet().length;

  HomeState copyWith({
    final HomeStatus? status,
    final List<Parcel>? parcels,
    final String? query,
    final List<SearchResult>? results,
    final String? errorMessage,
    final List<String>? missingColumns,
  }) {
    return HomeState(
      status: status ?? this.status,
      parcels: parcels ?? this.parcels,
      query: query ?? this.query,
      results: results ?? this.results,
      errorMessage: errorMessage,
      missingColumns: missingColumns ?? this.missingColumns,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    parcels,
    query,
    results,
    errorMessage,
    missingColumns,
  ];
}
