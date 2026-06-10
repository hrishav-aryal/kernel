import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:kernel/models/models.dart';
import 'package:kernel/services/home_service.dart';
import 'byte_item.dart';

class UnitSection extends StatelessWidget {
  final Unit unit;
  final List<CourseByte> bytes;
  final int unitIndex;
  final HomeData homeData;
  final Function(CourseByte) onBytePressed;
  final Function(int, int) getGlobalByteIndex;
  final Map<String, GlobalKey> byteKeys;
  final Map<String, GlobalKey> unitKeys;

  const UnitSection({
    super.key,
    required this.unit,
    required this.bytes,
    required this.unitIndex,
    required this.homeData,
    required this.onBytePressed,
    required this.getGlobalByteIndex,
    required this.byteKeys,
    required this.unitKeys,
  });

  @override
  Widget build(BuildContext context) {
    return SliverStickyHeader(
      header: Container(
        key: unitKeys[unit.id],
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: _buildUnitHeader(context),
      ),
      sliver: SliverPadding(
        padding: const EdgeInsets.fromLTRB(36, 16, 36, 32),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final byte = bytes[index];
            final isLast = index == bytes.length - 1;
            final globalIndex = getGlobalByteIndex(unitIndex, index);

            return Container(
              key: byteKeys[byte.id],
              child: ByteItem(
                byte: byte,
                unitColor: unit.colorValue,
                isLast: isLast,
                globalIndex: globalIndex,
                homeData: homeData,
                onTap: () => onBytePressed(byte),
              ),
            );
          }, childCount: bytes.length),
        ),
      ),
    );
  }

  Widget _buildUnitHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: unit.colorValue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border(
          bottom: BorderSide(color: unit.colorValue.withOpacity(0.8), width: 6),
          top: BorderSide(color: unit.colorValue.withOpacity(0.8), width: 0.5),
          left: BorderSide(color: unit.colorValue.withOpacity(0.8), width: 1),
          right: BorderSide(color: unit.colorValue.withOpacity(0.8), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'UNIT ${unitIndex + 1}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: unit.colorValue,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            unit.title,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
