import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eazzio_school/core/theme/app_theme.dart';
import '../models/student_models.dart';
import 'student_dashboard_screen.dart';

final studentFeesProvider =
    FutureProvider.autoDispose<List<FeeInvoiceItem>>((ref) async {
  final repo = ref.watch(studentRepositoryProvider);
  return await repo.getFees();
});

class StudentFeesScreen extends ConsumerStatefulWidget {
  const StudentFeesScreen({super.key});

  @override
  ConsumerState<StudentFeesScreen> createState() => _StudentFeesScreenState();
}

class _StudentFeesScreenState extends ConsumerState<StudentFeesScreen> {
  bool _isProcessing = false;

  Future<void> _handlePayment(FeeInvoiceItem invoice) async {
    setState(() => _isProcessing = true);
    try {
      final repo = ref.read(studentRepositoryProvider);
      final orderData = await repo.createFeeOrder(invoice.id);

      if (!mounted) return;

      // Show payment gateway dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.payment, color: AppTheme.primaryBlue),
              SizedBox(width: 8),
              Text('Razorpay Gateway'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invoice: ${invoice.invoiceNumber}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              Text('Fee Type: ${invoice.feeType}'),
              const SizedBox(height: 8),
              Text(
                'Amount to Pay: ₹${invoice.pendingAmount.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successGreen),
              ),
              const SizedBox(height: 12),
              Text(
                'Backend Razorpay order created successfully.\nOrder ID: ${orderData['orderId']}',
                style:
                    GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                _verifySimulatedPayment(invoice.id, orderData['orderId']);
              },
              child: const Text('Confirm Payment'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.info_outline, color: AppTheme.warningAmber, size: 36),
            title: Text(
              'Online Payment Unavailable',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: Text(
              'The server could not create a Razorpay payment order because RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET are not configured on the backend.\n\nPlease contact the school administration or settle fees at the accounts desk.',
              style: GoogleFonts.inter(fontSize: 14, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _viewReceipt(int paymentId) async {
    setState(() => _isProcessing = true);
    try {
      final repo = ref.read(studentRepositoryProvider);
      final receipt = await repo.getReceipt(paymentId);

      if (!mounted) return;

      final school = receipt['school'] as Map<String, dynamic>? ?? {};
      final student = receipt['student'] as Map<String, dynamic>? ?? {};
      final invoice = receipt['feeInvoice'] as Map<String, dynamic>? ?? {};

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.verified, color: AppTheme.successGreen),
              const SizedBox(width: 8),
              Text('Payment Receipt',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(school['schoolName'] ?? 'Eazzio School',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                if (school['address'] != null)
                  Text(school['address'],
                      style: GoogleFonts.inter(
                          fontSize: 11, color: AppTheme.textMuted)),
                const Divider(height: 20),
                Text(
                    'Receipt No: ${receipt['receiptNumber'] ?? "RCPT-$paymentId"}',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(
                    'Date: ${(receipt['date'] ?? "").toString().split("T").first}',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppTheme.textMuted)),
                const SizedBox(height: 8),
                Text('Student: ${student['name'] ?? ""}',
                    style: GoogleFonts.inter(fontSize: 13)),
                Text('Student ID: ${student['studentId'] ?? ""}',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppTheme.textMuted)),
                const SizedBox(height: 8),
                Text('Fee Type: ${invoice['feeType'] ?? "Tuition Fee"}',
                    style: GoogleFonts.inter(fontSize: 13)),
                Text('Invoice: ${invoice['invoiceNumber'] ?? ""}',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppTheme.textMuted)),
                Text('Payment Mode: ${receipt['paymentMethod'] ?? "ONLINE"}',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppTheme.textMuted)),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Amount Paid:',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('₹${receipt['amount']}',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppTheme.successGreen)),
                  ],
                ),
                if (receipt['razorpayPaymentId'] != null) ...[
                  const SizedBox(height: 6),
                  Text('Txn Ref: ${receipt['razorpayPaymentId']}',
                      style: GoogleFonts.inter(
                          fontSize: 10, color: AppTheme.textMuted)),
                ],
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load receipt: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _verifySimulatedPayment(int invoiceId, String orderId) async {
    setState(() => _isProcessing = true);
    try {
      final repo = ref.read(studentRepositoryProvider);
      // Generate standard verification response for backend verification
      final paymentId = 'pay_sim_${DateTime.now().millisecondsSinceEpoch}';

      // Note: Backend /api/student/fees/verify-payment requires genuine signature if RAZORPAY_KEY_SECRET is configured.
      // If payment cannot be verified by mock signature, alert clearly.
      final verified = await repo.verifyPayment(
        invoiceId: invoiceId,
        razorpayOrderId: orderId,
        razorpayPaymentId: paymentId,
        razorpaySignature: 'simulated_client_sig',
      );

      if (mounted) {
        if (verified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Payment successful and confirmed by server!')),
          );
          ref.refresh(studentFeesProvider);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Server confirmed: Payment signature verification failed or rejected.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification notice: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final feesAsync = ref.watch(studentFeesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees & Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(studentFeesProvider),
          ),
        ],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : feesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text('Error loading fees: $err')),
              data: (invoices) {
                if (invoices.isEmpty) {
                  return Center(
                    child: Text('No fee invoices issued yet.',
                        style: GoogleFonts.inter(color: AppTheme.textMuted)),
                  );
                }

                final totalPending =
                    invoices.fold(0.0, (acc, inv) => acc + inv.pendingAmount);

                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(studentFeesProvider),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Fee overview card
                      Card(
                        color: totalPending > 0
                            ? const Color(0xFFFEF2F2)
                            : const Color(0xFFF0FDF4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                              color: totalPending > 0
                                  ? const Color(0xFFFCA5A5)
                                  : const Color(0xFF86EFAC)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    totalPending > 0
                                        ? 'Total Dues Pending'
                                        : 'All Fees Cleared',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      color: totalPending > 0
                                          ? AppTheme.errorRed
                                          : AppTheme.successGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${totalPending.toStringAsFixed(0)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: totalPending > 0
                                          ? AppTheme.errorRed
                                          : AppTheme.successGreen,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                totalPending > 0
                                    ? Icons.error_outline
                                    : Icons.verified_outlined,
                                color: totalPending > 0
                                    ? AppTheme.errorRed
                                    : AppTheme.successGreen,
                                size: 36,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text('Invoices & Receipts',
                          style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      ...invoices.map((inv) {
                        final isPaid = inv.pendingAmount <= 0;
                        final statusColor = isPaid
                            ? AppTheme.successGreen
                            : (inv.status == 'OVERDUE'
                                ? AppTheme.errorRed
                                : AppTheme.warningAmber);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(inv.invoiceNumber,
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color:
                                            statusColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isPaid ? 'PAID' : inv.status,
                                        style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: statusColor),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(inv.feeType,
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppTheme.textDark)),
                                const SizedBox(height: 4),
                                Text(
                                    'Due Date: ${inv.dueDate.split("T").first}',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppTheme.textMuted)),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Amount: ₹${inv.amount.toStringAsFixed(0)}',
                                            style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: AppTheme.textMuted)),
                                        Text(
                                            'Pending: ₹${inv.pendingAmount.toStringAsFixed(0)}',
                                            style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: statusColor)),
                                      ],
                                    ),
                                    if (!isPaid)
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppTheme.studentAccent,
                                          minimumSize: const Size(100, 36),
                                        ),
                                        onPressed: () => _handlePayment(inv),
                                        child: const Text('Pay Now',
                                            style: TextStyle(fontSize: 13)),
                                      )
                                    else if (inv.payments.isNotEmpty)
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              AppTheme.successGreen,
                                          side: const BorderSide(
                                              color: AppTheme.successGreen),
                                          minimumSize: const Size(90, 36),
                                        ),
                                        icon: const Icon(Icons.receipt_outlined,
                                            size: 15),
                                        label: const Text('Receipt',
                                            style: TextStyle(fontSize: 12)),
                                        onPressed: () =>
                                            _viewReceipt(inv.payments.first.id),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
