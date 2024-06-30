import 'package:flutter/material.dart';

// User Model
class User {
  final String id; // unique ID for the user
  final String name; // name of the user
  final String phoneNumber; // phone number of the user

  User({required this.id, required this.name, required this.phoneNumber});
}

// Ride Request Model
class RideRequest {
  final String id; // unique ID for the ride request
  final User user; // the user who made the ride request.
  final String pickupLocation; // the pickup location
  final String dropoffLocation; // the dropoff location
  final DateTime requestTime; // the time when the ride was requested

  RideRequest({
    required this.id,
    required this.user,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.requestTime,
  });
}

// Vehicle Model
class Vehicle {
  final String id; // unique ID for the vehicle
  final String type; // type of the vehicle
  String location; // current location of the vehicle
  bool isAvailable; // availability of the vehicle

  Vehicle({
    required this.id,
    required this.type,
    required this.location,
    this.isAvailable = true,
  });
}

// Ride Service Class
class RideService {
  List<Vehicle> _vehicles = [
    Vehicle(id: 'V1', type: 'Car', location: ''),
    Vehicle(id: 'V2', type: 'Car2', location: ''),
  ];
  List<RideRequest> _activeRides = [];

  // returns the list of active ride requests
  List<RideRequest> getActiveRides() => _activeRides;

  // returns the list of vehicles
  List<Vehicle> getVehicles() => _vehicles;

  // processes a ride request by assigning an available vehicle and creates an exception if no vehicles are available
  void requestRide(RideRequest request) {
    print('Requesting ride for user: ${request.user.name}');
    try {
      final availableVehicle = _vehicles.firstWhere(
            (v) => v.isAvailable,
        orElse: () => throw Exception('No available vehicles'),
      );
      availableVehicle.isAvailable = false;
      availableVehicle.location = request.pickupLocation; // Set the location based on user input
      _activeRides.add(request);
      print('Ride confirmed for ${request.user.name} with vehicle ${availableVehicle.id}');
    } catch (e) {
      throw Exception('No available vehicles');
    }
  }

  // completes a ride and marks the vehicle as available
  void completeRide(String rideId) {
    final ride = _activeRides.firstWhere((r) => r.id == rideId);
    final vehicle = _vehicles.firstWhere((v) => v.id == ride.id);
    vehicle.isAvailable = true;
    _activeRides.remove(ride);
    print('Ride completed for ride ID $rideId');
  }

  // resets the ride service by clearing active rides and resetting vehicle availability
  void resetService() {
    _activeRides.clear();
    _vehicles.forEach((v) => v.isAvailable = true);
    print('Ride service has been reset.');
  }
}

// dashboard screen for managing ride requests and displaying vehicle status.
class DashboardScreen extends StatefulWidget {
  final RideService rideService;

  DashboardScreen({required this.rideService});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  bool _showTables = false; // flag to show/hide tables
  String? _errorMessage; // error message for ride request failures

  @override
  void initState() {
    super.initState();
    print('DashboardScreen initState');
  }

  // submits a ride request and updates the UI
  void _submitRequest() {
    print('Submit request button pressed');
    if (_formKey.currentState!.validate()) {
      final user = User(
        id: DateTime.now().toString(),
        name: _nameController.text,
        phoneNumber: _phoneController.text,
      );
      final request = RideRequest(
        id: DateTime.now().toString(),
        user: user,
        pickupLocation: _pickupController.text,
        dropoffLocation: _dropoffController.text,
        requestTime: DateTime.now(),
      );
      try {
        widget.rideService.requestRide(request);
        setState(() {
          _showTables = true; // show the tables after the first ride request
          _errorMessage = null;
        });
        print('Ride request submitted successfully.');
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
        print('Error requesting ride: $e');
      }
    } else {
      print('Form validation failed.');
    }
  }

  // resets the ride service and updates the UI
  void _resetService() {
    widget.rideService.resetService();
    setState(() {
      _showTables = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('DashboardScreen build method called');
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Service Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetService, // Reset button
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _pickupController,
                      decoration: InputDecoration(labelText: 'Pickup Location'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the pickup location';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _dropoffController,
                      decoration: InputDecoration(labelText: 'Dropoff Location'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the dropoff location';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitRequest,
                      child: Text('Request Ride'),
                    ),
                    if (_errorMessage != null) ...[
                      SizedBox(height: 20),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 20),
              if (_showTables) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: rideRequestsTable(),
                ),
                SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: vehiclesTable(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // builds the table to display active ride requests
  Widget rideRequestsTable() {
    print('Building ride requests table');
    return DataTable(
      columns: const [
        DataColumn(label: Text('Request ID')),
        DataColumn(label: Text('User ID')),
        DataColumn(label: Text('User')),
        DataColumn(label: Text('Pickup')),
        DataColumn(label: Text('Dropoff')),
        DataColumn(label: Text('Request Time')),
      ],
      rows: widget.rideService.getActiveRides().map((ride) {
        return DataRow(cells: [
          DataCell(Text(ride.id)), // Request ID
          DataCell(Text(ride.user.id)), // User ID
          DataCell(Text(ride.user.name)), // User name
          DataCell(Text(ride.pickupLocation)), // Pickup location
          DataCell(Text(ride.dropoffLocation)), // Dropoff location
          DataCell(Text(ride.requestTime.toString())), // Request time
        ]);
      }).toList(),
    );
  }

  // builds the table to display vehicle status.
  Widget vehiclesTable() {
    print('Building vehicles table');
    return DataTable(
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Type')),
        DataColumn(label: Text('Location')),
        DataColumn(label: Text('Availability')),
      ],
      rows: widget.rideService.getVehicles().map((vehicle) {
        return DataRow(cells: [
          DataCell(Text(vehicle.id)),
          DataCell(Text(vehicle.type)),
          DataCell(Text(vehicle.location)),
          DataCell(Text(vehicle.isAvailable ? 'Available' : 'In Use')),
        ]);
      }).toList(),
    );
  }
}

// Main Function to Run the App
void main() {
  print('main function called');
  final rideService = RideService();
  runApp(MyApp(rideService: rideService));
}

// root widget of the App.
class MyApp extends StatelessWidget {
  final RideService rideService;

  MyApp({required this.rideService});

  @override
  Widget build(BuildContext context) {
    print('MyApp build method called');
    return MaterialApp(
      title: 'Autonomous Ride Service',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DashboardScreen(rideService: rideService),
    );
  }
}
