import 'package:flutter/material.dart';
import 'package:bigshop/viewobject/customized_detail.dart';
import 'package:bigshop/viewobject/product.dart';

class AttributeDetailIntentHolder {
  const AttributeDetailIntentHolder({
    @required this.product,
    @required this.attributeDetail,
  });
  final Product product;
  final List<CustomizedDetail> attributeDetail;
}
