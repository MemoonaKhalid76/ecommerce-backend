import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Skeleton extends StatelessWidget {
  final double? height;
  final double? width;
  final double borderRadius;

  const Skeleton({super.key, this.height, this.width, this.borderRadius = 12});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ProductSkeletonGrid extends StatelessWidget {
  const ProductSkeletonGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 4, // Show 4 skeletons
      itemBuilder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(child: Skeleton(borderRadius: 12)),
              
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(height: 12, width: 80),
                    SizedBox(height: 8),
                    Skeleton(height: 12, width: double.infinity),
                    SizedBox(height: 4),
                    Skeleton(height: 12, width: 100),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Skeleton(height: 16, width: 60),
                         Skeleton(height: 14, width: 30),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BannerSkeleton extends StatelessWidget {
  const BannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: const Skeleton(height: 180, width: double.infinity),
    );
  }
}
