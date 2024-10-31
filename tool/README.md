# Raiden encoder/decoder tool

```shell
echo 00: 43 65 87 09 89 67 45 23 | xxd -r > a
./bin/tool --key=12345678987654321e1e1e1e95959595 a b
echo 00: d5 e3 8f 4b c4 ff d2 ed | xxd -r > expected
diff b expected
```

The tool can read key from RAIDEN_KEY environment variable,
if `--key` is not specified. The key can contains
underscores (`_`) for easy reading, they are ignored by
the tool.
