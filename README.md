# Bloc Toolkit

This package, `bloc_toolkit`, provides a complete set of tools for efficient and flexible state management in Flutter
applications using the Bloc pattern. It is designed to simplify the development of adaptive and dynamic applications by
offering advanced functions for loading, reloading, updating and initializing data.

## DataBloc

The `DataBloc` class is the core of the package. It is a generic class that provides a complete set of tools for
managing the state of a data source. It is designed to be used as a base class for implementing business logic in the
application.

### Features

- **DataBloc**: A generic class for managing the state of a data source.
- **State Management**: Supports various states like loading, loaded, error, and idle.
- **Event Handling**: Handles different events such as loading, reloading, updating, and initializing data.
- **Error Handling**: Provides mechanisms to handle exceptions.

### Create your data bloc

```
class AnimalBloc extends DataBloc<String, String> {
  AnimalBloc({required AnimalRepository animalRepository})
      : _animalRepository = animalRepository;
  final AnimalRepository _animalRepository;

  @override
  FutureOr<String> loadData(DataS<String> oldState, LoadDataE<String> event) {
    return _animalRepository.getAnimal(event.params!);
  }
}
```

### Build your widgets
```
BlocProvider(
          create: (_) => AnimalBloc(animalRepository: AnimalRepository()),
          child: BlocConsumer<AnimalBloc, DataS<String>>(
            listener: (context, state) {
              if (state is ErrorS<String>) {
                _showSnackBar(context, 'Loading animal error: ${state.error}');
              } 
            },
            builder: (context, state) {
              if (state is UnloadedDataS<String>) {
                return ...
              }
              if (state is LoadingDataS<String>) {
                return ...
              }
              if (state is LoadedDataS<String, String>) {
                return ...
              }
              if (state is ReloadingDataS<String, String>) {
                return ...
              }
              return ...
            },
          ),
        )
```

### Add events
```
        final animalBloc = context.read<AnimalBloc>();
        
        animalBloc.add(const LoadDataE(params: 'some args'));       
        //or       
        animalBloc.add(InitializeDataE('dog')) 
        
        ...
        
        //then you can
        animalBloc.add(const ReloadDataE(params: 'some args')) 
        // or
        animalBloc.add(UpdateDataE((currentData) => 'cat'));
```

### States
The DataBloc class can be in one of the following states:  

#### Base States
* `abstract DataS:` The base state for all states.
* `abstract IdleS:` The base state when nothing is happening.
* `abstract LoadingS:` The base state when data is loading or reloading.
* `abstract ErrorS:` The base state when there is an error.
#### Data unloaded states
* `abstract UnloadedS:` The base state for all unloaded states.
* `UnloadedDataS:` The initial state when no data is loaded.
* `LoadingDataS:` The state when data is being loaded.
* `LoadingDataErrorS:` The state when a data loading error occurred.
#### Data loaded states
* `abstract LoadedS:` The base state for all loaded states.
* `LoadedDataS:` The state when data has been successfully loaded or initialized successfully
* `ReloadingDataS:` The state when data is being reloaded.
* `ReloadingDataErrorS:` The state when a data reload error occurred.

### Events
The DataBloc class can handle the following events:  
* `LoadDataE:` Event for initial data loading.
* `InitializeDataE:` Event to initialize data without loading.
* `ReloadDataE:` Event to reload data when it has already been loaded or initialized.
* `UpdateDataE:` Event to update data when it is already loaded or initialized.



#### Classes relationships

![Classes relationships](https://github.com/dadagov125/bloc_toolkit/blob/main/docs/class_relations.png?raw=true)


#### State machine

![Classes relationships](https://github.com/dadagov125/bloc_toolkit/blob/main/docs/state_machine.png?raw=true)

### Error handling

By default, all errors thrown during data loading are converted to DataException which can be received in
LoadingDataErrorS or ReloadingDataErrorS states. Therefore, they will not get into `BlocObserver.onError`, 
but you can handle them in `BlocObserver.onChange`

```
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    final nextState = change.nextState;
    if (nextState is ErrorS) {
      final error = nextState.error;
      if (error is UnhandledDataException) {
        _logger.f('UnhandledDataException',
            error: error.error, stackTrace: error.stackTrace);
        //TODO: send to analytics
      }
    }
  }
```

If you want to handle errors in `BlocObserver.onError` you should override this behavior using 
the `overridedOnLoadingError` and `overridedOnReloadingError` methods when implementing your DataBloc .

```
void _$onLoadingError(
  DataException error,
  UnloadedDataS<String> state,
  Emitter<DataS<String>> emit, {
  String? params,
}) {
  if (error is UnhandledDataException) {
    throw error;
  }
  emit(LoadingDataErrorS(error, params: params));
  emit(const UnloadedDataS());
}

void _$onReloadingError(
  DataException error,
  LoadedS<String, String> state,
  Emitter<DataS<String>> emit, {
  String? params,
}) {
  if (error is UnhandledDataException) {
    throw error;
  }
  emit(ReloadingDataErrorS(state, error, params: params));
  emit(LoadedDataS(state.data, params: state.params));
}

class AnimalBloc extends DataBloc<String, String> {
  AnimalBloc({
    required AnimalRepository animalRepository,
    super.overridedOnLoadingError = _$onLoadingError,
    super.overridedOnReloadingError = _$onReloadingError,
  })
}
```
Then in `BlocObserver.onError` you can handle them

```
 @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if (error is UnhandledDataException) {
      final originError = error.error;
      final originStackTrace = error.stackTrace;
      //send to sentry...
    }
  }
```
#### Custom DataExceptions
To properly handle user errors (e.g. http errors) you must implement the `DataException` interface and they must be 
thrown in repositories. Otherwise all errors will be converted to `UnhandledDataException` 
which implements the `DataException` interface.



## ListBloc

ListBloc is an extended DataBloc for convenient work with lists with the ability to sort and filter list items.

`ListBloc` by default has DateS<List<T>> where T is the type of the element in the list. 

`ListBloc` has ListParams<T> with a list of filters(FilterPredicate) and a comparator(Comparator) for sorting elements.

`ApplyParamsE` extends UpdateDataE and accepts ListParams parameters.


## SelectBloc

For convenience, the implementation of selecting an item from a list is implemented by `SelectBloc`.
It does not extend `DataBloc`, but is a regular `Bloc`.

`SelectBloc` has only two states `SelectS`, when the item is not selected, and `SelectedS`, if the item is selected.

`SelectBloc` can handle only one event `SelectE`, which takes the item that should be selected or unselected if null is passed.
