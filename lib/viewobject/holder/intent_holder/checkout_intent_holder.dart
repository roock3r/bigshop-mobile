import 'package:bigshop/viewobject/basket.dart';
import 'package:flutter/cupertino.dart';

class CheckoutIntentHolder {
  const CheckoutIntentHolder({
    @required this.basketList,
  });
  final List<Basket> basketList;
}
