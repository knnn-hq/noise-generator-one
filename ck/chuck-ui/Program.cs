using System;

using tui_netcore;

namespace chuck_ui {
    class Program {
        static void Main(string[] args) {
			Tui window = new Tui();
			window.Title = " Chuck UI ";
			window.Body = "This is a dullscreen window";
			window.DrawOk();
        }
    }
}
