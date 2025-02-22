import torch

if __name__ == "__main__":
    if torch.cuda.is_available():
        print("CUDA ist verfügbar. Sie können GPU-beschleunigtes Training verwenden.")
    else:
        print("CUDA ist nicht verfügbar. Das Training erfolgt auf der CPU.")