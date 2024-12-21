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
