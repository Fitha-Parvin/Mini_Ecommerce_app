import 'package:ecommerce_app/screens/paymentscreen.dart';
import 'package:ecommerce_app/services/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  LatLng? _currentPosition;
  String userAddress = "Fetching your location...";
  bool isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // Fetch User Location
  Future<void> _getUserLocation() async {
    try {
      Position? position = await LocationService.getCurrentLocation();
      if (position != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          userAddress = placemarks.isNotEmpty
              ? "${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}"
              : "Location found, but address unavailable.";
          isLoadingLocation = false;
        });
      } else {
        _showLocationError();
      }
    } catch (e) {
      _showLocationError();
    }
  }

  void _showLocationError() {
    setState(() {
      userAddress = "Failed to fetch location. Enable GPS & Try Again.";
      isLoadingLocation = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error fetching location!")),
    );
  }

  void handleOrderPlacement() {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a delivery location first.")),
      );
      return;
    }

    // Navigate to Payment Screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaymentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 📍 Address Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 3,
                  )
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.deepPurple, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: isLoadingLocation
                        ? const Text("Fetching address...", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
                        : Text(userAddress, style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 📍 Google Map Section
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 3,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _currentPosition == null
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition!,
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId("current_location"),
                        position: _currentPosition!,
                      ),
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Proceed to Payment Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: handleOrderPlacement,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text("Proceed to Payment", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
