namespace Blatt4 {
    public class ClampingBorderBehavior : BorderBehavior {
        public override int GetPixelValue(int i, int j, Image image) {
            // i and j out of range
            if (image.Width <= i || image.Height <= j)
                return 0;
            var clampedI = Math.Clamp(i, 0, image.Width);
            var clampedJ =  Math.Clamp(j, 0, image.Height);
            return image.ScanLines![clampedJ, clampedI];
        }
    }
}
