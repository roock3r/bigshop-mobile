import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bigshop/api/common/ps_resource.dart';
import 'package:bigshop/api/common/ps_status.dart';
import 'package:bigshop/provider/common/ps_provider.dart';
import 'package:bigshop/repository/product_repository.dart';
import 'package:bigshop/utils/utils.dart';
import 'package:bigshop/viewobject/holder/product_parameter_holder.dart';
import 'package:bigshop/viewobject/product.dart';

class DiscountProductProvider extends PsProvider {
  DiscountProductProvider({@required ProductRepository repo, int limit = 0})
      : super(repo, limit) {
    _repo = repo;
    //isDispose = false;
    print('DiscountProductProvider : $hashCode');
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });

    productListStream = StreamController<PsResource<List<Product>>>.broadcast();
    subscription =
        productListStream.stream.listen((PsResource<List<Product>> resource) {
      updateOffset(resource.data.length);

      _productList = Utils.removeDuplicateObj<Product>(resource);

      if (resource.status != PsStatus.BLOCK_LOADING &&
          resource.status != PsStatus.PROGRESS_LOADING) {
        isLoading = false;
      }

      if (!isDispose) {
        notifyListeners();
      }
    });
  }
  ProductRepository _repo;
  PsResource<List<Product>> _productList =
      PsResource<List<Product>>(PsStatus.NOACTION, '', <Product>[]);

  PsResource<List<Product>> get productList => _productList;
  StreamSubscription<PsResource<List<Product>>> subscription;
  StreamController<PsResource<List<Product>>> productListStream;

  ProductParameterHolder discountProductParameterHolder =
      ProductParameterHolder().getDiscountParameterHolder();
  @override
  void dispose() {
    //_repo.cate.close();
    subscription.cancel();
    isDispose = true;
    print('Discount Product Provider Dispose: $hashCode');
    super.dispose();
  }

  Future<dynamic> loadProductList(
      ProductParameterHolder productParameterHolder) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    await _repo.getProductList(productListStream, isConnectedToInternet, limit,
        offset, PsStatus.PROGRESS_LOADING, productParameterHolder);
  }

  Future<dynamic> nextProductList(
      ProductParameterHolder productParameterHolder) async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();

    if (!isLoading && !isReachMaxData) {
      super.isLoading = true;

      await _repo.getProductList(productListStream, isConnectedToInternet,
          limit, offset, PsStatus.PROGRESS_LOADING, productParameterHolder);
    }
  }

  Future<dynamic> resetDiscountProductList(
      ProductParameterHolder productParameterHolder) async {
    isLoading = true;

    updateOffset(0);

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    await _repo.getProductList(productListStream, isConnectedToInternet, limit,
        offset, PsStatus.PROGRESS_LOADING, productParameterHolder);
  }
}
