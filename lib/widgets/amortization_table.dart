import 'package:flutter/material.dart';
import 'package:loanpal/logic/emi_calculator.dart';
import 'package:loanpal/utils/currency_utils.dart';
import 'package:loanpal/ui/theme.dart';

class AmortizationTable extends StatefulWidget {
  final List<AmortizationRow> rows;

  const AmortizationTable({super.key, required this.rows});

  @override
  State<AmortizationTable> createState() => _AmortizationTableState();
}

class _AmortizationTableState extends State<AmortizationTable> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Amortization Schedule',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(height: 1, thickness: 1),
          // INFO: Fixed height is required because the table lives inside a
          // SingleChildScrollView. Without a bounded height the inner
          // ListView would have unconstrained height and fail to render.
          SizedBox(
            height: 400,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Scrollbar(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 600,
                        maxWidth: constraints.maxWidth > 600 ? constraints.maxWidth : 600,
                      ),
                      child: Column(
                        children: [
                      Container(
                        color: LoanPalTheme.primaryNavy,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: Row(
                          children: [
                            _buildHeaderCell('Month', flex: 1),
                            _buildHeaderCell('Opening Bal', flex: 2),
                            _buildHeaderCell('EMI', flex: 2),
                            _buildHeaderCell('Interest', flex: 2),
                            _buildHeaderCell('Principal', flex: 2),
                            _buildHeaderCell('Closing Bal', flex: 2),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.rows.length,
                          itemBuilder: (context, index) {
                            final AmortizationRow row = widget.rows[index];
                            final bool isLast = index == widget.rows.length - 1;
                            return Container(
                              decoration: BoxDecoration(
                                color: index % 2 == 0
                                    ? Colors.white
                                    : LoanPalTheme.background,
                                border: Border(
                                  bottom: BorderSide(
                                    color: LoanPalTheme.outlineColor.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              child: Row(
                                children: [
                                  _buildDataCell(row.month.toString(), flex: 1),
                                  _buildDataCell(CurrencyUtils.formatINR(row.openingBalance), flex: 2),
                                  _buildDataCell(CurrencyUtils.formatINR(row.emi), flex: 2),
                                  _buildDataCell(
                                    CurrencyUtils.formatINR(row.interest),
                                    flex: 2,
                                    color: LoanPalTheme.burdenHigh,
                                  ),
                                  _buildDataCell(
                                    CurrencyUtils.formatINR(row.principal),
                                    flex: 2,
                                    color: LoanPalTheme.primaryNavy,
                                  ),
                                  _buildDataCell(
                                    isLast ? '₹0.00 ✓' : CurrencyUtils.formatINR(row.closingBalance),
                                    flex: 2,
                                    isBold: isLast,
                                    color: isLast ? LoanPalTheme.burdenLow : null,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
            },
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, {required int flex, Color? color, bool isBold = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: color ?? LoanPalTheme.textSecondary,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}
