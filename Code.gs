// ============================================================
//  Avighn Medicare — Google Apps Script Backend
//  Deploy as: Web App → Execute as: Me → Access: Anyone
// ============================================================

// ── Sheet names ───────────────────────────────────────────────
const SHEET_PRODUCTS = "Products";
const SHEET_IMAGES = "ProductImages";

// ── Column definitions ────────────────────────────────────────
const PRODUCTS_COLS = [
  "id",
  "name",
  "description",
  "price",
  "discountPercentage",
  "brand",
  "imageUrls",
  "category",
  "dosage",
  "uses",
  "prescriptionRequired",
  "inStock",
];
const IMAGES_COLS = [
  "imageId",
  "productId",
  "url",
  "altText",
  "sortOrder",
  "isPrimary",
];

// ── Entry points ──────────────────────────────────────────────
function doGet(e) {
  try {
    const action =
      e && e.parameter && e.parameter.action
        ? e.parameter.action
        : "";

    if (action === "getProducts") {
      const rows = sheetToObjects(
        getSheet(SHEET_PRODUCTS),
        PRODUCTS_COLS,
      );
      return jsonResponse(ok(rows));
    }

    if (action === "getImages") {
      const pid = e.parameter.productId || "";
      const all = sheetToObjects(getSheet(SHEET_IMAGES), IMAGES_COLS);
      const data = pid
        ? all.filter((r) => String(r.productId) === String(pid))
        : all;
      return jsonResponse(ok(data));
    }

    if (action === "ping") {
      return jsonResponse(
        ok({
          message: "Avighn Medicare API is live!",
          ts: new Date().toISOString(),
        }),
      );
    }

    // No action — return status (useful to verify deployment in browser)
    return jsonResponse(
      ok({
        status: "Avighn Medicare API running",
        actions: ["getProducts", "getImages", "ping"],
      }),
    );
  } catch (err) {
    return jsonResponse(error("GET error: " + err.message));
  }
}

function doPost(e) {
  try {
    const body = JSON.parse(e.postData.contents);
    const action = body.action;
    const data = body.data || {};

    let result;
    switch (action) {
      case "addProduct":
        result = addProduct(body.data);
        break;
      case "updateProduct":
        result = updateProduct(body.id, body.data);
        break;
      case "deleteProduct":
        result = deleteProduct(body.id);
        break;
      case "toggleStock":
        result = toggleStock(body.id, body.inStock);
        break;
      case "addImageUrl":
        result = addImageUrl(body);
        break;
      case "uploadImage":
        result = uploadImage(body);
        break;
      case "deleteImage":
        result = deleteImage(body.imageId, body.productId);
        break;
      case "setPrimaryImage":
        result = setPrimaryImage(body.imageId, body.productId);
        break;
      default:
        result = error("Unknown action: " + action);
    }
    return jsonResponse(result);
  } catch (err) {
    return jsonResponse(error("POST error: " + err.message));
  }
}

// ── Sheet helpers (same pattern as your working project) ──────
function getSheet(name) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  let sheet = ss.getSheetByName(name);

  if (!sheet) {
    sheet = ss.insertSheet(name);
    const headers =
      name === SHEET_PRODUCTS ? PRODUCTS_COLS : IMAGES_COLS;
    sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
    // Style header row
    const hdrRange = sheet.getRange(1, 1, 1, headers.length);
    hdrRange.setFontWeight("bold");
    hdrRange.setBackground("#00897B");
    hdrRange.setFontColor("#FFFFFF");
    sheet.setFrozenRows(1);
  }

  return sheet;
}

function sheetToObjects(sheet, cols) {
  const data = sheet.getDataRange().getValues();
  if (data.length <= 1) return []; // empty or header-only
  return data.slice(1).map((row) => {
    const obj = {};
    cols.forEach((col, i) => {
      obj[col] = row[i];
    });
    return obj;
  });
}

function findRowIndex(sheet, colIndex, value) {
  const lastRow = sheet.getLastRow();
  if (lastRow < 2) return -1;
  const values = sheet
    .getRange(2, colIndex + 1, lastRow - 1, 1)
    .getValues();
  for (let i = 0; i < values.length; i++) {
    if (String(values[i][0]).trim() === String(value).trim())
      return i + 2; // 1-based, skip header
  }
  return -1;
}

function now() {
  return new Date().toISOString();
}

function ok(payload) {
  return { success: true, data: payload };
}
function error(msg) {
  return { success: false, message: msg };
}

function jsonResponse(payload) {
  return ContentService.createTextOutput(
    JSON.stringify(payload),
  ).setMimeType(ContentService.MimeType.JSON);
}

// ── Products ──────────────────────────────────────────────────
function addProduct(d) {
  if (!d) return error("Product data is missing");
  if (!d.id) return error("Product id is required");
  if (!d.name || String(d.name).trim() === "")
    return error("Product name is required");

  const sheet = getSheet(SHEET_PRODUCTS);
  if (findRowIndex(sheet, 0, d.id) !== -1)
    return error("Product ID already exists: " + d.id);

  sheet.appendRow([
    String(d.id).trim(),
    String(d.name || "").trim(),
    String(d.description || "").trim(),
    parseFloat(d.price) || 0,
    parseFloat(d.discountPercentage) || 0,
    String(d.brand || "").trim(),
    String(d.imageUrls || "").trim(),
    String(d.category || "").trim(),
    String(d.dosage || "").trim(),
    String(d.uses || "").trim(),
    toStr(d.prescriptionRequired),
    toStr(d.inStock !== undefined ? d.inStock : true),
  ]);

  return ok({ id: d.id });
}

function updateProduct(id, d) {
  if (!id) return error("Product ID is required");
  if (!d) return error("Product data is required");

  const sheet = getSheet(SHEET_PRODUCTS);
  const row = findRowIndex(sheet, 0, id);
  if (row === -1) return error("Product not found: " + id);

  sheet
    .getRange(row, 1, 1, 12)
    .setValues([
      [
        String(d.id || id).trim(),
        String(d.name || "").trim(),
        String(d.description || "").trim(),
        parseFloat(d.price) || 0,
        parseFloat(d.discountPercentage) || 0,
        String(d.brand || "").trim(),
        String(d.imageUrls || "").trim(),
        String(d.category || "").trim(),
        String(d.dosage || "").trim(),
        String(d.uses || "").trim(),
        toStr(d.prescriptionRequired),
        toStr(d.inStock !== undefined ? d.inStock : true),
      ],
    ]);

  return ok({ id });
}

function deleteProduct(id) {
  if (!id) return error("Product ID is required");

  const sheet = getSheet(SHEET_PRODUCTS);
  const row = findRowIndex(sheet, 0, id);
  if (row === -1) return error("Product not found: " + id);

  sheet.deleteRow(row);

  // Cascade: delete associated images
  const imgSheet = getSheet(SHEET_IMAGES);
  const lastRow = imgSheet.getLastRow();
  if (lastRow > 1) {
    const imgData = imgSheet
      .getRange(2, 1, lastRow - 1, 2)
      .getValues();
    for (let i = imgData.length - 1; i >= 0; i--) {
      if (String(imgData[i][1]).trim() === String(id).trim()) {
        imgSheet.deleteRow(i + 2);
      }
    }
  }

  return ok({ id });
}

function toggleStock(id, inStock) {
  if (!id) return error("Product ID is required");

  const sheet = getSheet(SHEET_PRODUCTS);
  const row = findRowIndex(sheet, 0, id);
  if (row === -1) return error("Product not found: " + id);

  sheet.getRange(row, 12).setValue(inStock ? "TRUE" : "FALSE");
  return ok({ id, inStock });
}

// ── Images ────────────────────────────────────────────────────
function addImageUrl(b) {
  if (!b.productId) return error("productId is required");
  if (!b.url) return error("url is required");

  const sheet = getSheet(SHEET_IMAGES);
  const imgId = b.imageId || "img-" + new Date().getTime();

  sheet.appendRow([
    imgId,
    String(b.productId).trim(),
    String(b.url).trim(),
    String(b.altText || "").trim(),
    parseInt(b.sortOrder) || 0,
    b.isPrimary ? "TRUE" : "FALSE",
  ]);

  if (b.isPrimary) clearPrimaries(sheet, imgId, b.productId);
  syncImageUrls(b.productId);

  return ok({ imageId: imgId, url: b.url });
}

function uploadImage(b) {
  try {
    if (!b.productId) return error("productId is required");
    if (!b.data) return error("image data is required");

    const bytes = Utilities.base64Decode(b.data);
    const blob = Utilities.newBlob(
      bytes,
      b.mimeType || "image/jpeg",
      b.fileName || "image.jpg",
    );
    const fldrs = DriveApp.getFoldersByName("Avighn Medicare Images");
    const folder = fldrs.hasNext()
      ? fldrs.next()
      : DriveApp.createFolder("Avighn Medicare Images");
    const file = folder.createFile(blob);

    file.setSharing(
      DriveApp.Access.ANYONE_WITH_LINK,
      DriveApp.Permission.VIEW,
    );

    const url =
      "https://drive.google.com/uc?export=view&id=" + file.getId();
    const imgId = "img-" + new Date().getTime();
    const sheet = getSheet(SHEET_IMAGES);

    sheet.appendRow([
      imgId,
      String(b.productId).trim(),
      url,
      String(b.altText || "").trim(),
      parseInt(b.sortOrder) || 0,
      b.isPrimary ? "TRUE" : "FALSE",
    ]);

    if (b.isPrimary) clearPrimaries(sheet, imgId, b.productId);
    syncImageUrls(b.productId);

    return ok({ imageId: imgId, url });
  } catch (err) {
    return error("Upload failed: " + err.message);
  }
}

function deleteImage(imageId, productId) {
  if (!imageId) return error("imageId is required");

  const sheet = getSheet(SHEET_IMAGES);
  const row = findRowIndex(sheet, 0, imageId);
  if (row === -1) return error("Image not found: " + imageId);

  sheet.deleteRow(row);
  if (productId) syncImageUrls(productId);

  return ok({ imageId });
}

function setPrimaryImage(imageId, productId) {
  if (!imageId) return error("imageId is required");
  if (!productId) return error("productId is required");

  const sheet = getSheet(SHEET_IMAGES);
  clearPrimaries(sheet, imageId, productId);

  const row = findRowIndex(sheet, 0, imageId);
  if (row !== -1) sheet.getRange(row, 6).setValue("TRUE");

  syncImageUrls(productId);
  return ok({ imageId });
}

// ── Private helpers ───────────────────────────────────────────
function clearPrimaries(imgSheet, exceptId, productId) {
  const lastRow = imgSheet.getLastRow();
  if (lastRow < 2) return;
  const data = imgSheet.getRange(2, 1, lastRow - 1, 6).getValues();
  data.forEach((row, i) => {
    if (
      String(row[1]).trim() === String(productId).trim() &&
      String(row[0]).trim() !== String(exceptId).trim()
    ) {
      imgSheet.getRange(i + 2, 6).setValue("FALSE");
    }
  });
}

function syncImageUrls(productId) {
  const imgSheet = getSheet(SHEET_IMAGES);
  const lastRow = imgSheet.getLastRow();
  if (lastRow < 2) return;

  const rows = imgSheet.getRange(2, 1, lastRow - 1, 6).getValues();
  const primary = [],
    others = [];

  rows.forEach((r) => {
    if (String(r[1]).trim() === String(productId).trim() && r[2]) {
      String(r[5]).toUpperCase() === "TRUE"
        ? primary.push(r[2])
        : others.push(r[2]);
    }
  });

  const prodSheet = getSheet(SHEET_PRODUCTS);
  const row = findRowIndex(prodSheet, 0, productId);
  if (row !== -1)
    prodSheet
      .getRange(row, 7)
      .setValue(primary.concat(others).join(","));
}

// TRUE/FALSE string from any truthy value
function toStr(val) {
  return val === true || String(val).toUpperCase() === "TRUE"
    ? "TRUE"
    : "FALSE";
}

// ── Optional: run manually from editor to pre-create sheets ──
function setupSheets() {
  const ps = getSheet(SHEET_PRODUCTS);
  const is = getSheet(SHEET_IMAGES);
  Logger.log("Products rows: " + (ps.getLastRow() - 1));
  Logger.log("Images rows:   " + (is.getLastRow() - 1));
  Logger.log("Avighn Medicare is ready!");
}
