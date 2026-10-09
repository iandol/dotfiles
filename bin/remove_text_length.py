"""
Inkscape extension: Remove Text Length.

Removes the textLength and lengthAdjust attributes from every <text>
element in the document.
"""
import inkex


class RemoveTextLength(inkex.EffectExtension):
    def effect(self):
        # Deselect all items in the document
        self.svg.selection.clear()

        # Find all text elements in the entire document
        for text in self.svg.xpath('//svg:text'):
            # Remove textLength attribute if present
            if 'textLength' in text.attrib:
                del text.attrib['textLength']
            # Remove lengthAdjust attribute if present
            if 'lengthAdjust' in text.attrib:
                del text.attrib['lengthAdjust']


if __name__ == '__main__':
    RemoveTextLength().run()
