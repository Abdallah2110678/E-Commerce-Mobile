import 'package:flutter/material.dart';
import 'package:mobile_project/utils/constants/sizes.dart';

class TGridLayout extends StatelessWidget {
  const TGridLayout({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.mainAxisExtent = 288,
    this.crossAxisCount = 2,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  final int itemCount;
  final crossAxisCount;
  final double? mainAxisExtent;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollPhysics physics;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: mainAxisExtent,
        mainAxisSpacing: TSizes.gridViewSpacing,
        crossAxisSpacing: TSizes.gridViewSpacing,
      ),
      itemBuilder: itemBuilder,
    );
  }
}
