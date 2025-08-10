# FitImagesToPageWidth.py
# Resize all Writer images to fit within the text area width, keeping aspect ratio.

import uno
from com.sun.star.awt import Size

def _get_style_families(doc):
    return doc.getStyleFamilies()

def _usable_text_width_for_style(page_styles, style_name):
    try:
        style = page_styles.getByName(style_name)
    except Exception:
        return None
    try:
        page_width = style.getPropertyValue("Width")
        left_margin = style.getPropertyValue("LeftMargin")
        right_margin = style.getPropertyValue("RightMargin")
        usable = int(page_width) - int(left_margin) - int(right_margin)
        return usable if usable > 0 else None
    except Exception:
        return None

def _get_image_collection(doc):
    xname_access = doc.getGraphicObjects()
    names = list(xname_access.getElementNames())
    return xname_access, names

def _page_style_at_anchor(doc, text_range):
    text = text_range.getText()
    cursor = text.createTextCursorByRange(text_range)
    try:
        return cursor.PageStyleName
    except Exception:
        try:
            return doc.getCurrentController().getViewCursor().PageStyleName
        except Exception:
            return None

def fit_images_to_page_width(*args):
    doc = XSCRIPTCONTEXT.getDocument()
    controller = doc.getCurrentController()

    page_styles = _get_style_families(doc).getByName("PageStyles")
    usable_width_cache = {}

    resized_count = 0
    skipped_count = 0
    errors = []

    try:
        xname_access, names = _get_image_collection(doc)
    except Exception as e:
        errors.append(f"Could not retrieve image collection: {e!r}")
        _inform_user(controller, resized_count, skipped_count, errors)
        return

    for name in names:
        try:
            img = xname_access.getByName(name)  # com.sun.star.text.TextGraphicObject
            anchor = img.getAnchor()

            style_name = _page_style_at_anchor(doc, anchor)
            if not style_name:
                skipped_count += 1
                continue

            usable = usable_width_cache.get(style_name)
            if usable is None:
                usable = _usable_text_width_for_style(page_styles, style_name)
                usable_width_cache[style_name] = usable

            if not usable or usable <= 0:
                skipped_count += 1
                continue

            # Normalize from relative to absolute, if present
            try:
                if getattr(img, "RelativeWidth", 0):
                    img.RelativeWidth = 0
                if getattr(img, "RelativeHeight", 0):
                    img.RelativeHeight = 0
            except Exception:
                pass

            curr_w = int(getattr(img, "Width"))
            curr_h = int(getattr(img, "Height"))

            if curr_w <= 0 or curr_h <= 0:
                skipped_count += 1
                continue

            if curr_w > usable:
                new_w = int(usable)
                new_h = max(1, int(round(curr_h * (new_w / float(curr_w)))))
                try:
                    img.setSize(Size(new_w, new_h))
                except Exception:
                    img.Width = new_w
                    img.Height = new_h
                resized_count += 1
            else:
                skipped_count += 1

        except Exception as e:
            errors.append(f"{name}: {e!r}")

    _inform_user(controller, resized_count, skipped_count, errors)

def _inform_user(controller, resized_count, skipped_count, errors):
    # Cross-platform feedback without dialogs
    msg = f"Fit Images: Resized={resized_count}, Skipped={skipped_count}, Errors={len(errors)}"
    try:
        si = controller.getStatusIndicator()
        if si:
            si.start("Fit Images", 1)
            si.setText(msg)
            si.end()
    except Exception:
        pass
    print(msg)
    for e in errors:
        print("  -", e)

# Export AFTER definitions
g_exportedScripts = (fit_images_to_page_width,)
