#include <errno.h>
#include <stdio.h>

static int printFileBytes(const char *path) {
  unsigned char bytes[16] = {0};
  const size_t maximumByteCount = sizeof(bytes);
  FILE *file = fopen(path, "rb");

  if (file == NULL) {
    fprintf(stderr, "ERROR open_read_failed | path=%s errno=%d\n", path, errno);
    return 1;
  }

  const size_t byteCount = fread(bytes, 1, maximumByteCount, file);
  if (ferror(file)) {
    fprintf(stderr, "ERROR read_failed | path=%s errno=%d\n", path, errno);
    fclose(file);
    return 1;
  }
  if (fclose(file) != 0) {
    fprintf(stderr, "ERROR close_read_failed | path=%s errno=%d\n", path,
            errno);
    return 1;
  }

  printf("bytes | path=%s count=%zu hex=", path, byteCount);
  for (size_t index = 0; index < byteCount; ++index) {
    printf("%02x", bytes[index]);
  }
  putchar('\n');
  return 0;
}

int main(int argumentCount, char *arguments[]) {
  const char *path = argumentCount == 2 ? arguments[1] : "ccs-utf8-output.bin";
  static const unsigned char payload[] = {0x00, 0x00, 0x22, 0x74};
  FILE *file = fopen(path, "wb, ccs=UTF-8");

  if (file == NULL) {
    fprintf(stderr,
            "ERROR open_write_failed | path=%s mode=wb,ccs=UTF-8 errno=%d\n",
            path, errno);
    return 1;
  }
  if (fwrite(payload, 1, sizeof(payload), file) != sizeof(payload)) {
    fprintf(stderr, "ERROR write_failed | path=%s errno=%d\n", path, errno);
    fclose(file);
    return 1;
  }
  if (fclose(file) != 0) {
    fprintf(stderr, "ERROR close_write_failed | path=%s errno=%d\n", path,
            errno);
    return 1;
  }

  printf("write_complete | path=%s mode=wb,ccs=UTF-8 payload_size=%zu\n", path,
         sizeof(payload));
  return printFileBytes(path);
}
