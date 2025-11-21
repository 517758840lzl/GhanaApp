import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        title: Text('loanContract'.tr),
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
            Text(
              'loanContractIntro'.tr,
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: 16),
             Text(
              'loanContractTermsTitle'.tr,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
             Text(
              'loanContractTerms'.tr,
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 16),
             Text(
              'loanContractDetailsTitle'.tr,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${'contractDatePrefix'.tr} ${DateTime.now().toLocal().toString().split(' ')[0]}',
            ),
            Text('${'dearSirMadam'.tr}：$name'),
            const SizedBox(height: 8),
             Text('followingYourLoanApplication'.tr),
            const SizedBox(height: 8),
            Text(
              '${'loanAmount'.tr} (${'currencyUSD'.tr}): $loanAmount',
            ),
            // Text('Annual Percentage Rate (APR): $apr'),
            Text(
              '${'singleRepaymentAmount'.tr} (${'currencyUSD'.tr}): $singleRepaymentAmount',
            ),
            // Text('Loan Term (Days): $loanTerm'),
            Text(
              '${'amountCredited'.tr} (${'currencyUSD'.tr}): $amountCredited',
            ),
            // Text('Interest (\$): $interest'),
            Text(
              '${'repaymentFrequency'.tr}: ${'singleRepayment'.tr}',
            ),
            Text('${'dueDate'.tr}: $dueDate'),
            Text('${'name'.tr}: $name'),
            Text('${'idCardNumber'.tr}: $idCardNumber'),
            Text('${'walletAccount'.tr}: $receivingBankCardNumber'),
            // Text('Late Penalty: $latePenalty'),
            Text('${'loanMobilePhoneNumber'.tr}: $loanMobilePhoneNumber'),
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
