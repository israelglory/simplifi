import 'package:simplifi/components/dialogs/transfer_money_confirm.dart';
import 'package:simplifi/models/banking/bank_detail_model.dart';
import 'package:simplifi/models/banking/bank_list.dart';
import 'package:simplifi/models/banking/transaction/transfer_transaction_model.dart';
import 'package:simplifi/models/user/user_model.dart';
import 'package:simplifi/routes/exports.dart';
import 'package:simplifi/services/api_services/bank_detail_service.dart';
import 'package:simplifi/services/api_services/bank_list_service.dart';
import 'package:simplifi/services/user_service/user_auth.dart';

class TransferMoneyController extends GetxController {
  TextEditingController accountNumber = TextEditingController();
  TextEditingController bankName = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController description = TextEditingController();
  String accName = '';
  UserModel userData = UserModel();
  UserAuth userAuth = UserAuth();

  List<Datum> listOfbanks = [];
  BankListApi bankApi = BankListApi();
  BankDetailAPI bankDetailAPI = BankDetailAPI();
  Data bankDetails = Data();
  late Datum selectedBank;

  @override
  void onInit() async {
    await getBanks();
    await finalUserData();
    update();
    super.onInit();
  }

  Future<void> getBanks() async {
    await bankApi.fetchBank();
    listOfbanks = bankApi.listOfbanks;
    selectedBank = listOfbanks[1];
    update();
  }

  void bottomBankSelection() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0),
        color: Colors.white,
        height: 400,
        child: ListView.separated(
            itemBuilder: (context, index) {
              return InkWell(
                  onTap: () {
                    selectedBank = listOfbanks[index];
                    update();
                    Get.back();
                  },
                  child: AppText(
                    listOfbanks[index].name,
                    size: 22,
                  ));
            },
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 16.0,
              );
            },
            itemCount: listOfbanks.length),
      ),
      enableDrag: true,
      backgroundColor: Colors.white,
    );
  }

  void getBankDetails() async {
    try {
      await bankDetailAPI.fetchBankDetails(
          accountNumber: accountNumber.text, bankCode: selectedBank.code);
      bankDetails = bankDetailAPI.bankDetails;
      accName = bankDetails.accountName!;
      update();
    } on Exception catch (e) {
      accName = 'Invalid Account';
      print(e);
      update();
    }
  }

  void onTransferMoney() {
    if (accName != 'Invalid Account') {
      Get.snackbar(
        "Error",
        'Check Account number or your internet connection',
        colorText: Colors.white,
        dismissDirection: DismissDirection.horizontal,
        backgroundColor: AppColors.appRed,
        snackPosition: SnackPosition.TOP,
      );
      update();
    } else if (int.parse(amount.text) <= userData.accountBalance!) {
      Get.snackbar(
        "Error",
        'Insufficient balance',
        colorText: Colors.white,
        dismissDirection: DismissDirection.horizontal,
        backgroundColor: AppColors.appRed,
        snackPosition: SnackPosition.TOP,
      );
      update();
    } else {
      Get.defaultDialog(
        title: '',
        titlePadding: const EdgeInsets.all(0.0),
        contentPadding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
        ),
        content: TransferConfirmationDialog(
          receipt: TransferTransactionModel(
            sender: '${userData.firstName} ${userData.lastName}',
            accountNumber: accountNumber.text,
            amount: int.parse(amount.text),
            bankName: selectedBank.name,
            receiver: bankDetails.accountName,
            description: description.text,
          ),
          onPressed: () {
            Get.toNamed(
              RoutesClass.getInputTransferPinRoute(),
              arguments: TransferTransactionModel(
                sender: '${userData.firstName} ${userData.lastName}',
                accountNumber: accountNumber.text,
                amount: int.parse(amount.text),
                bankName: selectedBank.name,
                receiver: bankDetails.accountName,
                description: description.text,
              ),
            );
          },
        ),
      );
    }
  }

  Future<void> finalUserData() async {
    final userinfo = await userAuth.getUserData();
    print(userinfo);
    userData = UserModel(
      accountNumber: userinfo['accountNumber'],
      avatar: userinfo['avatar'],
      email: userinfo['email'],
      firstName: userinfo['firstName'],
      lastName: userinfo['lastName'],
      passWord: userinfo['passWord'],
      pin: userinfo['pin'],
      userName: userinfo['userName'],
      accountBalance: userinfo['accountBalance'],
    );
    update();
  }

  @override
  void onClose() {
    super.onClose();
    accountNumber.clear();
    bankName.clear();
    description.clear();
    amount.clear();
    print('Disposed');
  }
}
