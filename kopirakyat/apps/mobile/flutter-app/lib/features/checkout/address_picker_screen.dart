import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../data/providers.dart';
import '../../models/address.dart';
import '../../services/geocoding_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';

// Kemang, Jakarta Selatan — sensible default center since that's where the
// prototype's only pickup store is.
const _defaultCenter = LatLng(-6.2607, 106.8133);

class AddressPickerScreen extends ConsumerStatefulWidget {
  const AddressPickerScreen({super.key, this.initialAddress});

  final Address? initialAddress;

  @override
  ConsumerState<AddressPickerScreen> createState() => _AddressPickerScreenState();
}

class _AddressPickerScreenState extends ConsumerState<AddressPickerScreen> {
  final _mapController = MapController();
  final _searchController = TextEditingController();

  late LatLng _center;
  String? _address;
  bool _resolvingAddress = true;
  bool _searching = false;
  List<GeocodingResult> _results = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialAddress;
    _center = initial != null ? LatLng(initial.latitude, initial.longitude) : _defaultCenter;
    _address = initial?.formattedAddress;
    _resolveAddress(_center);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _resolveAddress(LatLng center) async {
    setState(() => _resolvingAddress = true);
    final address = await ref.read(geocodingServiceProvider).reverseGeocode(center.latitude, center.longitude);
    if (!mounted) return;
    setState(() {
      _address = address;
      _resolvingAddress = false;
    });
  }

  void _onMapMoved(LatLng center) {
    _center = center;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () => _resolveAddress(center));
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _searching = true);
    final results = await ref.read(geocodingServiceProvider).search(query);
    if (!mounted) return;
    setState(() {
      _results = results;
      _searching = false;
    });
  }

  void _selectResult(GeocodingResult result) {
    final target = LatLng(result.latitude, result.longitude);
    _mapController.move(target, 16);
    setState(() {
      _results = [];
      _searchController.text = result.displayName;
    });
    _onMapMoved(target);
    FocusScope.of(context).unfocus();
  }

  void _confirm() {
    final address = _address;
    if (address == null) return;
    Navigator.of(context).pop(Address(
      formattedAddress: address,
      latitude: _center.latitude,
      longitude: _center.longitude,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) _onMapMoved(camera.center);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.kopirakyat.kopi_rakyat_app',
              ),
            ],
          ),
          IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: const Icon(Icons.location_pin, size: 42, color: AppColors.brand),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleIconButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Material(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadius.control),
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: _search,
                            decoration: InputDecoration(
                              hintText: 'Cari alamat...',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              suffixIcon: _searching
                                  ? const Padding(
                                      padding: EdgeInsets.all(14),
                                      child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.search),
                                      onPressed: () => _search(_searchController.text),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_results.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.control),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final result in _results)
                            ListTile(
                              dense: true,
                              leading: const Icon(Icons.place_outlined, size: 20),
                              title: Text(result.displayName, style: const TextStyle(fontSize: 13)),
                              onTap: () => _selectResult(result),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ALAMAT DI PIN', style: TextStyle(fontSize: 11, letterSpacing: 0.09, color: AppColors.inkAlpha(0.55))),
                    const SizedBox(height: 6),
                    _resolvingAddress
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : Text(_address ?? 'Geser peta untuk memilih lokasi', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    const SizedBox(height: 14),
                    BrandButton(
                      label: 'Konfirmasi alamat',
                      enabled: !_resolvingAddress && _address != null,
                      onTap: _confirm,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
