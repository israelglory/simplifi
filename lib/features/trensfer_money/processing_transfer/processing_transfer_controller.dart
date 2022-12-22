import 'package:ezanimation/ezanimation.dart';
import 'package:simplifi/models/banking/transaction/transfer_transaction_model.dart';
import 'package:simplifi/routes/exports.dart';
import 'package:simplifi/services/transaction_services/send_transfer_transaction.dart';

class ProcessTransferController extends GetxController
    with GetTickerProviderStateMixin {
  SendTransferTransaction transfer = SendTransferTransaction();
  final transaction = Get.arguments as TransferTransactionModel;
  EzAnimation ezAnimation =
      EzAnimation(200.0, 300.0, const Duration(seconds: 1));
  bool isLoading = true;
  @override
  void onInit() async {
    super.onInit();
    animateIt();
  }

  void animateIt() async {
    isLoading = true;
    update();
    ezAnimation.start();
    update();

    await Future.delayed(
      const Duration(seconds: 3),
    );

    ezAnimation.repeat(rev: true);
    update();

    await sendMoney();

    ezAnimation.stop();
    update();
    isLoading = false;
    update();
  }

  @override
  void onClose() {
    super.onClose();
    ezAnimation.dispose();
    print('Disposed');
  }

  Future<void> sendMoney() async {
    try {
      await transfer.sendTransfer(
          sender: transaction.sender!,
          amount: transaction.amount!,
          receiver: transaction.receiver!,
          bankName: transaction.bankName!,
          accountNumber: transaction.accountNumber!,
          description: transaction.description!);
    } on FirebaseException catch (e) {
      Get.snackbar(
        "Error",
        e.message!,
        colorText: Colors.white,
        dismissDirection: DismissDirection.horizontal,
        backgroundColor: AppColors.appRed,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}
