using System;
using System.Linq;
using System.Numerics;
using System.Threading;

namespace Cube
{
    class Program
    {
        static void Main(string[] args)
        {
            new Program().Run();
        }

        private int _viewSizeX = 70;
        private int _viewSizeY = 40;
        private int _sleepMs = 50;
        private float[,] _zbuf;
        private ConsoleColor[,] _buf, _pbuf;

        private (float, ConsoleColor)[] _colors =
        {
            (1.010f, ConsoleColor.DarkGray),
            (1.013f, ConsoleColor.DarkRed),
            (1.015f, ConsoleColor.DarkYellow),
            (1.018f, ConsoleColor.Yellow),
        };

        void ClearBuf()
        {
            var t = _pbuf;
            _pbuf = _buf;
            _buf = t;
            for (int x = 0; x < _buf.GetLength(0); x++)
            {
                for (int y = 0; y < _buf.GetLength(1); y++)
                {
                    _buf[x, y] = ConsoleColor.Black;
                    _zbuf[x, y] = float.MinValue;
                }
            }
        }

        void Run()
        {
            if (Console.WindowWidth < _viewSizeX)
            {
                Console.WindowWidth = _viewSizeX + 3;
            }
            if (Console.WindowHeight < _viewSizeY)
            {
                Console.WindowHeight = _viewSizeY + 3;
            }

            ConsoleColor beforeForeground = Console.ForegroundColor;
            ConsoleColor beforeBackground = Console.BackgroundColor;
            Console.CancelKeyPress += (sender, args) =>
            {
                Console.ForegroundColor = beforeForeground;
                Console.BackgroundColor = beforeBackground;

                Console.CursorLeft = 0;
                Console.CursorTop = _viewSizeY + 2;
            };

            _zbuf = new float[_viewSizeX, _viewSizeY];
            _buf = new ConsoleColor[_viewSizeX, _viewSizeY];
            _pbuf = new ConsoleColor[_viewSizeX, _viewSizeY];
            ClearBuf();

            var perspective = Matrix4x4.CreatePerspective(
                (float)Math.PI * 0.1f,
                8f / 14f * _viewSizeY / (float)_viewSizeX,
                0.1f,
                50f);

            float scale = 4.0f;
            int ptCount = 80;

            var pts = Enumerable.Range(0, ptCount + 1)
              .Select(i => i / (float)ptCount * 2f - 1f)
              .Select(i => i * scale)
              .SelectMany(i => new[] { -scale, scale }.Select(x => (i, x)))
              .SelectMany(ix =>
              {
                  var (i, x) = ix;
                  return new[]
                  {
                      new Vector4(i, x, x, 1),
                      new Vector4(i, x, -x, 1),

                      new Vector4(x, i, x, 1),
                      new Vector4(x, i, -x, 1),

                      new Vector4(x, x, i, 1),
                      new Vector4(x, -x, i, 1),
                  };
              })
              .Distinct()
              .ToArray();

            Console.Clear();
            var rootX = 2;
            var rootY = 0;
            for (int i = 0; i < _viewSizeY; i++)
            {
                Console.WriteLine();
            }

            var start = DateTime.Now;

            while (true)
            {
                var diff = DateTime.Now - start;
                var t = (float)diff.TotalSeconds;
                ClearBuf();
                foreach (var p in pts)
                {
                    var mat =
                      Matrix4x4.CreateRotationX((float)Math.PI * 0.4f * t) *
                      Matrix4x4.CreateRotationY((float)Math.PI * 0.13f * t) *
                      Matrix4x4.CreateRotationZ((float)Math.PI * 0.17f * t) *
                      Matrix4x4.CreateTranslation(0, 0, 10);
                    var m = Vector4.Transform(p, mat * perspective);
                    m.X /= m.W;
                    m.Y /= m.W;
                    m.Z /= m.W;
                    if (m.Z < 0) continue;

                    int x = (int)Math.Round((m.X + 0.5f) * _viewSizeX);
                    int y = (int)Math.Round((m.Y + 0.5f) * _viewSizeY);

                    if (x < 0) continue;
                    if (x >= _viewSizeX) continue;
                    if (y < 0) continue;
                    if (y >= _viewSizeY) continue;

                    if (!(_zbuf[x, y] < m.Z))
                    {
                        continue;
                    }

                    _zbuf[x, y] = m.Z;
                    _buf[x, y] = ConsoleColor.Yellow;
                    foreach (var c in _colors)
                    {
                        (float dist, ConsoleColor color) = c;
                        if (m.Z < dist || _colors.Last() == c)
                        {
                            _buf[x, y] = color;
                            break;
                        }
                    }
                }
                for (int y = 0; y < _buf.GetLength(1); y++)
                {
                    int lastx = -1;
                    Console.CursorLeft = rootX;
                    Console.CursorTop = rootY + y;
                    for (int x = 0; x < _buf.GetLength(0); x++)
                    {
                        if (_buf[x, y] != _pbuf[x, y])
                        {
                            if (lastx + 1 != x)
                            {
                                Console.CursorLeft = rootX + x;
                            }
                            Console.BackgroundColor = _buf[x, y];
                            Console.Write(" ");
                            lastx = x;
                        }
                    }
                }
                Thread.Sleep(_sleepMs);
            }
        }
    }
}
