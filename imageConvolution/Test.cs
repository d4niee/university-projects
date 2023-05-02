namespace Blatt4; 

public static class Test {
    
    private static BorderBehavior clamp = new ClampingBorderBehavior();
    private static BorderBehavior zero = new ZeroPaddingBorderBehavior();
    private static float[,] kernelHorizontal = KernelFactory.CreateHorizontalPrewitt();
    private static float[,] kernelVertical = KernelFactory.CreateVerticalPrewitt();
    private static Image image;
    
    public static void TestBild1() {
        image = new Image();
        image.ReadFromFile("Bild 1.pgm");
        // vertical prewitt - zero padded
        image.Convolve(kernelVertical, zero);
        image.WriteToFile("ZeroPadded/Ergebnis 1_vertical.pgm");
        // horizontal prewitt - zero padded
        image.Convolve(kernelHorizontal, zero);
        image.WriteToFile("ZeroPadded/Ergebnis 1_horizontal.pgm");
        // vertical prewitt - clamped
        image.Convolve(kernelVertical, clamp);
        image.WriteToFile("Clamped/Ergebnis 1_vertical.pgm");
        // horizontal prewitt - clamped
        image.Convolve(kernelHorizontal, clamp);
        image.WriteToFile("Clamped/Ergebnis 1_horizontal.pgm");
    }

    public static void TestBild2() {
        image = new Image();
        image.ReadFromFile("Bild 2.pgm");
        // box = 3
        image.Convolve(KernelFactory.CreateBoxFilter(3), zero);
        image.WriteToFile("ZeroPadded/Ergebnis 2_3.pgm");
        image.Convolve(KernelFactory.CreateBoxFilter(3), clamp);
        image.WriteToFile("Clamped/Ergebnis 2_3.pgm");
        // box = 11
        image.Convolve(KernelFactory.CreateBoxFilter(11), zero);
        image.WriteToFile("ZeroPadded/Ergebnis 2_11.pgm");
        image.Convolve(KernelFactory.CreateBoxFilter(11), clamp);
        image.WriteToFile("Clamped/Ergebnis 2_11.pgm");
        // box = 27
        image.Convolve(KernelFactory.CreateBoxFilter(27), zero);
        image.WriteToFile("ZeroPadded/Ergebnis 2_27.pgm");
        image.Convolve(KernelFactory.CreateBoxFilter(27), clamp);
        image.WriteToFile("Clamped/Ergebnis 2_27.pgm");
    }
}