# request_processing_system

A new Flutter project.

## Getting Started

import 'package:flutter/material.dart';

// User Model
    class User {
        final String id;
        final String name;
        final String phoneNumber;

        User({required this.id, required this.name, required this.phoneNumber});
    }

// Ride Request Model
    class RideRequest {
        final String id;
        final User user;
        final String pickupLocation;
        final String dropoffLocation;
        final DateTime requestTime;

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
        final String id;
        final String type;
        final String location;
        bool isAvailable;

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
            Vehicle(id: 'V1', type: 'Car', location: 'Location1'),
            Vehicle(id: 'V2', type: 'Car2', location: 'Location2'),
            // Add more vehicles as needed
        ];
        List<RideRequest> _activeRides = [];

        List<RideRequest> getActiveRides() => _activeRides;
        List<Vehicle> getVehicles() => _vehicles;

        void requestRide(RideRequest request) {
            final availableVehicle = _vehicles.firstWhere(
                (v) => v.isAvailable && v.location == request.pickupLocation,
                orElse: () => throw Exception('No available vehicles'));
            if (availableVehicle != null) {
                availableVehicle.isAvailable = false;
                _activeRides.add(request);
            print(
                'Ride confirmed for ${request.user.name} with vehicle ${availableVehicle.id}');
             }
        }

        void completeRide(String rideId) {
            final ride = _activeRides.firstWhere((r) => r.id == rideId);
            final vehicle = _vehicles.firstWhere((v) => v.id == ride.id);
            vehicle.isAvailable = true;
            _activeRides.remove(ride);
            print('Ride completed for ride ID $rideId');
        }
    }

// Dashboard Screen to Display Data
    class DashboardScreen extends StatelessWidget {
        final RideService rideService;

        DashboardScreen({required this.rideService});

        @override
        Widget build(BuildContext context) {
            return Scaffold(
                appBar: AppBar(
                    title: Text('Ride Service Dashboard'),
                ),
                body: Column(
                    children: [
                        Expanded(
                            child: rideRequestsTable(),
                        ),
                        Expanded(
                            child: vehiclesTable(),
                        ),
                    ],
                ),
            );
        }

        Widget rideRequestsTable() {
            return DataTable(
                columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('User')),
                    DataColumn(label: Text('Pickup')),
                    DataColumn(label: Text('Dropoff')),
                    DataColumn(label: Text('Request Time')),
                ],
                rows: rideService.getActiveRides().map((ride) {
                    return DataRow(cells: [
                        DataCell(Text(ride.id)),
                        DataCell(Text(ride.user.name)),
                        DataCell(Text(ride.pickupLocation)),
                        DataCell(Text(ride.dropoffLocation)),
                        DataCell(Text(ride.requestTime.toString())),
                    ]);
                }).toList(),
            );
        }

        Widget vehiclesTable() {
            return DataTable(
                columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Availability')),
                ],
                rows: rideService.getVehicles().map((vehicle) {
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
        final rideService = RideService();
        runApp(MyApp(rideService: rideService));
    }

    class MyApp extends StatelessWidget {
        final RideService rideService;

        MyApp({required this.rideService});

        @override
        Widget build(BuildContext context) {
            return MaterialApp(
                title: 'Autonomous Ride Service',
                theme: ThemeData(
                    primarySwatch: Colors.blue,
                ),
                home: DashboardScreen(rideService: rideService),
            );
        }
    }
"# ride_service_app" 
