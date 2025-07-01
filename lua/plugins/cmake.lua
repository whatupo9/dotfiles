return {
	"cdelledonne/vim-cmake",
	keys = {
		{
			"<leader>cc",
			":!cmake -G Ninja -S . -B build -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Debug && cmake --build build --config Debug<cr>",
		},
		{ "<leader>cx", ":!ninja clean<cr>" },
		{
			"<leader>cr",
			":!cmake -G Ninja -S . -B build -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release<cr>",
		},
	},
}
