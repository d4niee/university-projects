namespace Blatt4 {
    public class ZeroPaddingBorderBehavior : BorderBehavior {
        
        /**
         * returns the value of a pixel at the given i, j
         * position. If the position is out of bounce return 0.
         * @param i - width
         * @param j - height
         * @return pixel value
         */
        public override int GetPixelValue(int i, int j, Image image) {
            // i and j out of range
            if (image.Width <= i || image.Height <= j)
                return 0;
            if (i < 0 || j < 0)
                return 0;
            // else --> return pixel value
            return image.ScanLines![j, i];
        }
    }
}
