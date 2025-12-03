part of 'pages.dart';

class InternationalPage extends StatefulWidget {
  const InternationalPage({super.key});

  @override
  State<InternationalPage> createState() => _InternationalPageState();
}

class _InternationalPageState extends State<InternationalPage> {
  late InternationalViewModel internationalViewModel;

  // Controllers
  final weightController = TextEditingController();
  final searchController = TextEditingController();

  // Dropdown & Selection State
  final List<String> courierOptions = ["pos", "tiki"]; // International usually supports fewer
  String selectedCourier = "pos";

  int? selectedProvinceOriginId;
  int? selectedCityOriginId;
  
  // Country Selection State
  int? selectedCountryId;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    internationalViewModel = Provider.of<InternationalViewModel>(context, listen: false);
    
    // Load Provinces if empty
    if (internationalViewModel.provinceList.status == Status.notStarted) {
      internationalViewModel.getProvinceList();
    }
  }

  @override
  void dispose() {
    weightController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Same structure as HomePage
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // ================= INPUT CARD =================
                Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // 1. Courier & Weight
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedCourier,
                                items: courierOptions.map((c) => 
                                  DropdownMenuItem(value: c, child: Text(c.toUpperCase()))
                                ).toList(),
                                onChanged: (v) => setState(() => selectedCourier = v ?? "pos"),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: weightController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Berat (gr)'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 2. Origin Section (Indonesia)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Origin", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Row(
                          children: [
                            // Province Dropdown
                            Expanded(
                              child: Consumer<InternationalViewModel>(
                                builder: (context, vm, _) {
                                  if (vm.provinceList.status == Status.loading) {
                                    return const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)));
                                  }
                                  final provinces = vm.provinceList.data ?? [];
                                  return DropdownButton<int>(
                                    isExpanded: true,
                                    value: selectedProvinceOriginId,
                                    hint: const Text('Pilih provinsi'),
                                    items: provinces.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name ?? ''))).toList(),
                                    onChanged: (newId) {
                                      setState(() {
                                        selectedProvinceOriginId = newId;
                                        selectedCityOriginId = null;
                                      });
                                      if (newId != null) vm.getCityOriginList(newId);
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // City Dropdown
                            Expanded(
                              child: Consumer<InternationalViewModel>(
                                builder: (context, vm, _) {
                                  if (vm.cityOriginList.status == Status.loading) {
                                    return const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)));
                                  }
                                  final cities = vm.cityOriginList.data ?? [];
                                  // Validation logic
                                  final validId = cities.any((c) => c.id == selectedCityOriginId) ? selectedCityOriginId : null;
                                  
                                  return DropdownButton<int>(
                                    isExpanded: true,
                                    value: validId,
                                    hint: const Text('Pilih kota'),
                                    items: cities.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name ?? ''))).toList(),
                                    onChanged: (newId) => setState(() => selectedCityOriginId = newId),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),

                        // 3. Destination Section (International Search)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Destination (Country)", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        
                        // Search Bar
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Cari Negara (e.g. Japan)",
                            suffixIcon: selectedCountryId != null 
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      selectedCountryId = null;
                                      searchController.clear();
                                      isSearching = false;
                                    });
                                  },
                                ) 
                              : const Icon(Icons.search),
                          ),
                          onChanged: (val) {
                            setState(() {
                              isSearching = true;
                              selectedCountryId = null; // Reset selection when typing
                            });
                            // Trigger VM Search
                            Provider.of<InternationalViewModel>(context, listen: false).onSearchCountry(val);
                          },
                        ),

                        // Search Results List (Only shows when searching and not selected)
                        if (isSearching && selectedCountryId == null)
                          Container(
                            height: 150,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                            child: Consumer<InternationalViewModel>(
                              builder: (context, vm, _) {
                                if (vm.destinationList.status == Status.loading) {
                                  return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                                }
                                final results = vm.destinationList.data ?? [];
                                if (results.isEmpty) return const Center(child: Text("Negara tidak ditemukan"));

                                return ListView.builder(
                                  itemCount: results.length,
                                  itemBuilder: (context, index) {
                                    final country = results[index];
                                    return ListTile(
                                      title: Text(country.countryName ?? ""),
                                      onTap: () {
                                        setState(() {
                                          selectedCountryId = int.tryParse(country.countryId ?? "0");
                                          searchController.text = country.countryName ?? "";
                                          isSearching = false; // Hide list
                                        });
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 16),

                        // 4. Calculate Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedCityOriginId != null && selectedCountryId != null && weightController.text.isNotEmpty) {
                                internationalViewModel.checkInternationalShippingCost(
                                  originCityId: selectedCityOriginId!,
                                  destinationCountryId: selectedCountryId!,
                                  weight: int.parse(weightController.text),
                                  courier: selectedCourier,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Lengkapi semua field!'), backgroundColor: Colors.redAccent),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.all(16),
                            ),
                            child: const Text("Hitung Ongkir", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ================= OUTPUT CARD =================
                Card(
                  color: Colors.blue[50],
                  elevation: 2,
                  child: Consumer<InternationalViewModel>(
                    builder: (context, vm, _) {
                      switch (vm.costList.status) {
                        case Status.loading:
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator(color: Colors.black)),
                          );
                        case Status.error:
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(child: Text(vm.costList.message ?? 'Error', style: const TextStyle(color: Colors.red))),
                          );
                        case Status.completed:
                          if (vm.costList.data == null || vm.costList.data!.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: Text("Tidak ada data ongkir.")),
                            );
                          }
                          // Uses the new CardInternationalCost widget
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: vm.costList.data!.length,
                            itemBuilder: (context, index) => CardInternationalCost(
                              vm.costList.data!.elementAt(index),
                            ),
                          );
                        default:
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: Text("Isi data dan klik Hitung Ongkir.", style: TextStyle(color: Colors.black))),
                          );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Global Loading Overlay
          Consumer<InternationalViewModel>(
            builder: (context, vm, _) {
              if (vm.isLoading) {
                return Container(
                  color: Colors.black54, // Semi-transparent black
                  child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}