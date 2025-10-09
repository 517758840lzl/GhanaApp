import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../l10n/app_strings.dart';
import '../../../common/colors/app_colors.dart';

// 合同页面
class LoanContractPage extends StatelessWidget {
  const LoanContractPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final String loanAmount = args['loanAmount'] ?? "";
    final String singleRepaymentAmount = args['singleRepaymentAmount'] ?? "";
    final String amountCredited = args['amountCredited'] ?? "";
    final String interest = args['interest'] ?? "";
    final String dueDate = args['dueDate'] ?? "";
    final String name = args['name'] ?? "";
    final String idCardNumber = args['idCardNumber'] ?? "";
    final String receivingBankCardNumber =
        args['receivingBankCardNumber'] ?? "";
    final String loanMobilePhoneNumber = args['loanMobilePhoneNumber'] ?? "";

    return Scaffold(
      appBar: AppBar(
        backgroundColor:  AppColors.primaryColor,
        title: const Text(AppStrings.loanContract),
        titleTextStyle:TextStyle(color: Colors.white,fontSize: 20),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,color: Colors.white,),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text(
            //   'Loan Contract',
            //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            // ),
            const SizedBox(height: 5),
            const Text(
              AppStrings.loanContractIntro,
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.loanContractTermsTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.loanContractTerms,
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.loanContractDetailsTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppStrings.contractDatePrefix} ${DateTime.now().toLocal().toString().split(' ')[0]}',
            ),
            Text('${AppStrings.dearSirMadam}：$name'),
            const SizedBox(height: 8),
            const Text(AppStrings.followingYourLoanApplication),
            const SizedBox(height: 8),
            Text(
              '${AppStrings.loanAmount} (${AppStrings.currencyUSD}): $loanAmount',
            ),
            // Text('Annual Percentage Rate (APR): $apr'),
            Text(
              '${AppStrings.singleRepaymentAmount} (${AppStrings.currencyUSD}): $singleRepaymentAmount',
            ),
            // Text('Loan Term (Days): $loanTerm'),
            Text(
              '${AppStrings.amountCredited} (${AppStrings.currencyUSD}): $amountCredited',
            ),
            // Text('Interest (\$): $interest'),
            Text(
              '${AppStrings.repaymentFrequency}: ${AppStrings.singleRepayment}',
            ),
            Text('${AppStrings.dueDate}: $dueDate'),
            Text('${AppStrings.name}: $name'),
            Text('${AppStrings.idCardNumber}: $idCardNumber'),
            Text('${AppStrings.walletAccount}: $receivingBankCardNumber'),
            // Text('Late Penalty: $latePenalty'),
            Text('${AppStrings.loanMobilePhoneNumber}: $loanMobilePhoneNumber'),
            const SizedBox(height: 16),
            // const Text(
            //   'Complaint Officer',
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 8),
            // const Text(
            //   'If you have any concerns or complaints, please contact the complaint officer using the following information:',
            // ),
            // const SizedBox(height: 8),
            // const Text('Email: support@mobimeta.org'),
          ],
        ),
      ),
    );
  }
}
