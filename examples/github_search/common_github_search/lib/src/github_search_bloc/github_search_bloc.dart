import 'package:bloc/bloc.dart';

import 'package:common_github_search/common_github_search.dart';

const _debounceDuration = const Duration(milliseconds: 300);

class GithubSearchBloc extends Bloc<GithubSearchEvent, GithubSearchState> {
  GithubSearchBloc({required this.githubRepository})
      : super(SearchStateEmpty()) {
    on<TextChanged>(_onTextChanged, debounceTime(_debounceDuration));
  }

  final GithubRepository githubRepository;

  Stream<void> _onTextChanged(
    TextChanged event,
    Emit<GithubSearchState> emit,
  ) async* {
    final searchTerm = event.text;

    if (searchTerm.isEmpty) {
      emit(SearchStateEmpty());
      return;
    }

    emit(SearchStateLoading());

    try {
      final results = await githubRepository.search(searchTerm);
      emit(SearchStateSuccess(results.items));
    } catch (error) {
      emit(error is SearchResultError
          ? SearchStateError(error.message)
          : SearchStateError('something went wrong'));
    }
  }
}
