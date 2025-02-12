//
//  FlowLayout.swift
//  Magic Ive
//
//  Created by krishkumar on 2.06.2025.
//

import SwiftUI

/// A layout that arranges its subviews in a flow, accommodating alignments and spacing options.
///
/// After placing each subview, if there's no more horizontal space, the layout automatically
/// moves to the next line. The `alignment` property can be set to various SwiftUI alignment
/// values (e.g., `.leading`, `.center`, `.trailing`). The `horizontalSpacing` and `verticalSpacing`
/// control spacing between subviews. The `fitContentWidth` property can be toggled to have the
/// layout fill the parent’s width or adapt to the subviews’ widths.
struct FlowLayout: Layout {
	var horizontalSpacing: CGFloat = 8
	var verticalSpacing: CGFloat = 8
	var fitContentWidth: Bool = false
	var alignment: Alignment = .topLeading

	func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
		let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
		var height: CGFloat = 0
		let width: CGFloat = fitContentWidth ? 0 : (proposal.width ?? 0)
		var currentX: CGFloat = 0
		var currentY: CGFloat = 0

		for size in sizes {
			if fitContentWidth {
				currentX += size.width + horizontalSpacing
				height = max(height, size.height + verticalSpacing)
			} else {
				if currentX + size.width > width {
					currentX = 0
					currentY += size.height + verticalSpacing
				}

				currentX += size.width + horizontalSpacing
				height = max(height, currentY + size.height)
			}
		}

		return CGSize(width: fitContentWidth ? currentX : width, height: height)
	}

	func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
		var currentX: CGFloat = bounds.minX
		var currentY: CGFloat = bounds.minY
		let maxWidth = fitContentWidth ? .greatestFiniteMagnitude : bounds.width
		var rowSubviews = [(subview: LayoutSubview, size: CGSize)]()
		var rowWidth: CGFloat = 0
		var rowMaxHeight: CGFloat = 0

		for subview in subviews {
			let size = subview.sizeThatFits(.unspecified)

			if currentX + size.width > maxWidth {
				placeRow(rowSubviews, in: bounds, yOffset: currentY, totalRowWidth: rowWidth)

				currentX = bounds.minX
				currentY += rowMaxHeight + verticalSpacing
				rowSubviews.removeAll()
				rowWidth = 0
				rowMaxHeight = 0
			}

			rowSubviews.append((subview, size))
			rowWidth += size.width + horizontalSpacing
			rowMaxHeight = max(rowMaxHeight, size.height)
			currentX += size.width + horizontalSpacing
		}

		if !rowSubviews.isEmpty {
			placeRow(rowSubviews, in: bounds, yOffset: currentY, totalRowWidth: rowWidth)
		}
	}

	private func placeRow(_ rowSubviews: [(subview: LayoutSubview, size: CGSize)], in bounds: CGRect, yOffset: CGFloat, totalRowWidth: CGFloat) {
		var xOffset: CGFloat

		switch alignment {
		case .leading, .topLeading, .bottomLeading:
			xOffset = bounds.minX
		case .trailing, .topTrailing, .bottomTrailing:
			xOffset = bounds.maxX - totalRowWidth + horizontalSpacing
		default:
			xOffset = (bounds.width - totalRowWidth + horizontalSpacing) / 2
		}

		for (subview, size) in rowSubviews {
			subview.place(at: CGPoint(x: xOffset, y: yOffset), proposal: ProposedViewSize(size))
			xOffset += size.width + horizontalSpacing
		}
	}
}
