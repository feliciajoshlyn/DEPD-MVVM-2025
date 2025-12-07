part of 'widgets.dart';

class CardInternationalCost extends StatelessWidget {
  final InternationalCosts cost;
  const CardInternationalCost(this.cost, {super.key});

  // Helper: Dynamic Currency Formatter
  String currencyFormatter(double? value, String? currencyCode) {
    if (value == null) return "-";
    try {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: currencyCode ?? '\$', // Use API currency or default to $
        decimalDigits: 2,
      );
      return formatter.format(value);
    } catch (e) {
      return "$currencyCode $value";
    }
  }

  // Helper: Format ETD
  String formatEtd(String? etd) {
    if (etd == null || etd.isEmpty) return '-';
    return etd.replaceAll('day', 'hari').replaceAll('days', 'hari');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue[800]!),
      ),
      margin: const EdgeInsetsDirectional.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      color: Colors.white,
      
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // showModalBottomSheet(
          //   context: context,
          //   backgroundColor: Colors.transparent,
          //   isScrollControlled: true,
          //   builder: (context) {
          //     // We need a specific sheet for International data
          //     return InternationalShippingDetailSheet(cost: cost);
          //   },
          // );
        },
        child: ListTile(
          // 4. Leading Icon (Used 'public' to distinguish Int'l, but same colors)
          leading: CircleAvatar(
            backgroundColor: Colors.blue[50],
            child: Icon(Icons.public, color: Colors.blue[800]),
          ),
          
          // 5. Title Styling
          title: Text(
            "${cost.name ?? 'Kurir'}: ${cost.service}",
            style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.w700,
            ),
          ),
          
          // 6. Subtitle Styling (Exact layout match)
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Biaya: ${currencyFormatter(cost.cost, cost.currency)}",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Estimasi sampai: ${formatEtd(cost.etd)}",
                style: TextStyle(color: Colors.green[800]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}