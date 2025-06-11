#!/bin/bash

DATASET_DIR="$(cd "$(dirname "$0")" && pwd)"
TRAIN_DIR="${DATASET_DIR}/train"
VAL_DIR="${DATASET_DIR}/val"

echo "=== ImageNet-1K Dataset Check ==="
echo "Target Directory: $DATASET_DIR"
echo ""

# Check the number of classes
train_class_count=$(find "$TRAIN_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)
val_class_count=$(find "$VAL_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)

# Check the number of images
train_image_count=$(find "$TRAIN_DIR" -type f -iname '*.JPEG' | wc -l)
val_image_count=$(find "$VAL_DIR" -type f -iname '*.JPEG' | wc -l)

echo "Train Classes     : $train_class_count (expected: 1000)"
echo "Validation Classes: $val_class_count (expected: 1000)"
echo "Train Images      : $train_image_count (expected: ~1,281,167)"
echo "Validation Images : $val_image_count (expected: 50,000)"
echo ""

# Check for warnings
warn_flag=0

if [ "$train_class_count" -ne 1000 ]; then
    echo "❌ Warning: Train class count is not 1000"
    warn_flag=1
fi

if [ "$val_class_count" -ne 1000 ]; then
    echo "❌ Warning: Validation class count is not 1000"
    warn_flag=1
fi

if [ "$train_image_count" -ne 1281167 ]; then
    echo "❌ Warning: Train image count is less than expected"
    warn_flag=1
fi

if [ "$val_image_count" -ne 50000 ]; then
    echo "❌ Warning: Validation image count is not 50,000"
    warn_flag=1
fi

if [ "$warn_flag" -ne 0 ]; then
    echo ""
    echo "=== Suggested Action ==="
    echo "Dataset structure seems incomplete or incorrect."
    echo "Please reconstruct the dataset using the following files:"
    echo ""
    echo "  - ${DATASET_DIR}/ILSVRC2012_img_train.tar"
    echo "  - ${DATASET_DIR}/ILSVRC2012_img_val.tar"
    echo ""
else
    echo "✅ Dataset structure appears complete."
fi
