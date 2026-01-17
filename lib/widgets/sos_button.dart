import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ecoguide/services/location_service.dart';
import 'package:location/location.dart';

class SOSButton extends StatefulWidget {
  const SOSButton({super.key});

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSOS() {
    // Show Dialog IMMEDIATELY, don't wait for location
    showDialog(
      context: context,
      builder: (context) => const SOSDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.1).animate(_controller),
      child: InkWell(
        onTap: _handleSOS,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 44, 
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 1,
              )
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11, 
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SOSDialog extends StatefulWidget {
  const SOSDialog({super.key});

  @override
  State<SOSDialog> createState() => _SOSDialogState();
}

class _SOSDialogState extends State<SOSDialog> {
  final LocationService _locationService = LocationService();
  LocationData? _locationData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final loc = await _locationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _locationData = loc;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Impossible de localiser";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        debugPrint('Could not launch $launchUri');
      }
    } catch (e) {
       debugPrint('Error launching call: $e');
    }
  }

  Widget _buildEmergencyContact(String name, String number) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Colors.red,
        radius: 16,
        child: Icon(Icons.phone, color: Colors.white, size: 16),
      ),
      title: Text(name),
      subtitle: Text(number),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          elevation: 0,
        ),
        onPressed: () => _makePhoneCall(number),
        child: const Text('Appeler'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
          SizedBox(width: 10),
          Text('URGENCE SOS', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'En cas d\'urgence, contactez les secours.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Votre position actuelle :'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _isLoading 
                  ? const Center(
                      child: SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2)
                      )
                    )
                  : _error != null 
                      ? Text(_error!, style: const TextStyle(color: Colors.red))
                      : SelectableText(
                          'Lat: ${_locationData?.latitude?.toStringAsFixed(5) ?? "?"}\nLong: ${_locationData?.longitude?.toStringAsFixed(5) ?? "?"}',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                        ),
            ),
            const SizedBox(height: 16),
            const Text('Numéros d\'urgence :'),
            const SizedBox(height: 8),
            _buildEmergencyContact('Protection Civile', '198'),
            _buildEmergencyContact('Garde Nationale', '193'),
            _buildEmergencyContact('Sylvagri (Urgence)', '+216 12 345 678'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer', style: TextStyle(color: Colors.grey)),
        ),
      ],
    ); 
  }
}
