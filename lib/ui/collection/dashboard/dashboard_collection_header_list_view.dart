import 'package:bigshop/config/ps_config.dart';
import 'package:bigshop/constant/route_paths.dart';
import 'package:bigshop/provider/productcollection/product_collection_provider.dart';
import 'package:bigshop/repository/product_collection_repository.dart';
import 'package:bigshop/ui/collection/item/dashboard_collection_header_list_item.dart';
import 'package:bigshop/ui/common/ps_ui_widget.dart';
import 'package:bigshop/ui/product/collection_product/product_list_by_collection_id_view.dart';
import 'package:bigshop/utils/utils.dart';
import 'package:bigshop/viewobject/common/ps_value_holder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardCollectionHeaderListView extends StatefulWidget {
  const DashboardCollectionHeaderListView({Key key, @required this.shopId})
      : super(key: key);
  final String shopId;
  @override
  State<StatefulWidget> createState() => _CollectionHeaderListItem();
}

class _CollectionHeaderListItem extends State<DashboardCollectionHeaderListView>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  ProductCollectionProvider _productCollectionProvider;
  ProductCollectionRepository productCollectionRepository;
  PsValueHolder psValueHolder;
  dynamic data;

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _productCollectionProvider
            .nextProductCollectionListByShopId(widget.shopId);
      }
    });

    super.initState();
  }

  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;

  void checkConnection() {
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
      if (isConnectedToInternet && PsConfig.showAdMob) {
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    productCollectionRepository =
        Provider.of<ProductCollectionRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);

    if (!isConnectedToInternet && PsConfig.showAdMob) {
      print('loading ads....');
      checkConnection();
    }

    return ChangeNotifierProvider<ProductCollectionProvider>(
      lazy: false,
      create: (BuildContext context) {
        final ProductCollectionProvider provider =
            ProductCollectionProvider(repo: productCollectionRepository);
        provider.loadProductCollectionListByShopId(widget.shopId);
        _productCollectionProvider = provider;
        return _productCollectionProvider;
      },
      child: Consumer<ProductCollectionProvider>(builder: (BuildContext context,
          ProductCollectionProvider provider, Widget child) {
        return Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  Container(
                    child: RefreshIndicator(
                      child: ListView.builder(
                          shrinkWrap: true,
                          controller: _scrollController,
                          itemCount: provider.productCollectionList.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (provider.productCollectionList.data != null ||
                                provider.productCollectionList.data.isEmpty) {
                              return DashboardCollectionHeaderListItem(
                                productCollectionHeader:
                                    provider.productCollectionList.data[index],
                                onTap: () {
                                  Navigator.pushNamed(context,
                                      RoutePaths.productListByCollectionId,
                                      arguments: ProductListByCollectionIdView(
                                        productCollectionHeader: provider
                                            .productCollectionList.data[index],
                                        appBarTitle: provider
                                            .productCollectionList
                                            .data[index]
                                            .name,
                                      ));
                                },
                              );
                            } else {
                              return null;
                            }
                          }),
                      onRefresh: () {
                        return provider
                            .resetProductCollectionListByShopId(widget.shopId);
                      },
                    ),
                  ),
                  PSProgressIndicator(provider.productCollectionList.status)
                ],
              ),
            )
          ],
        );
      }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
