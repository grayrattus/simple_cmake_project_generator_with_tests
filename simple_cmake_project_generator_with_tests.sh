touch CMakeLists.txt
build_directory_name="build"
project_directory_name="Main"
project_entry_file_name="main.cpp"

primary_class_name="Basic"

test_file_name="$primary_class_name.cpp"
test_entry_file_name="master.cpp"
test_directory_name="test"

echo "Creating ${build_directory_name} as a build directory"
mkdir ${build_directory_name}

cat > CMakeLists.txt  << EOF
cmake_minimum_required(VERSION 3.4)

#Parametry konfiguracyjne cmake
set(CMAKE_CXX_COMPILER g++)#wymaga by g++ był na ścieżce
set(CMAKE_C_COMPILER gcc)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#Profil debug i maksymalny poziom debug info g3 oraz format debug info na dwarf-4 (musi być gdb w wersji 7)
set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_C_FLAGS_DEBUG '-g3 -gdwarf-4')
set(CMAKE_CXX_FLAGS_DEBUG '-g3 -gdwarf-4')

project(CPPtest)
enable_language(CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON) 
set(CMAKE_VERBOSE_MAKEFILE TRUE) 

add_subdirectory(${project_directory_name})

enable_testing()
EOF

echo "Creating main structure"
mkdir "$project_directory_name"
mkdir "$project_directory_name/src"
mkdir "$project_directory_name/include"
touch "$project_directory_name/$project_entry_file_name"
touch "$project_directory_name/src/$primary_class_name.cpp"
touch "$project_directory_name/include/$primary_class_name.hpp"

echo "Creating tests structure"
mkdir "$test_directory_name"
touch "$test_directory_name/$test_file_name"
touch "$test_directory_name/$test_entry_file_name"

echo "Creating $project_directory_name CMakeLists.txt"
cat > "$project_directory_name/CMakeLists.txt" << EOF 
cmake_minimum_required(VERSION 3.4)
project(${project_directory_name})

set(SOURCE_FILES "src/${primary_class_name}.cpp" "${project_entry_file_name}")
add_library(${project_directory_name} \${SOURCE_FILES})
target_include_directories(${project_directory_name} PUBLIC \${CMAKE_CURRENT_SOURCE_DIR}/include)
set_target_properties(${project_directory_name} PROPERTIES LINKER_LANGUAGE CXX)

find_package (Boost 1.58.0 COMPONENTS "unit_test_framework" REQUIRED)
set(SOURCE_TESTER_FILES ../${test_directory_name}/${test_entry_file_name} ../${test_directory_name}/${test_file_name})

include_directories(${project_directory_name}/include \${Boost_INCLUDE_DIRS})
add_executable("${primary_class_name}" \${SOURCE_TESTER_FILES})
target_link_libraries("${primary_class_name}" "${project_directory_name}" \${Boost_UNIT_TEST_FRAMEWORK_LIBRARY})

add_custom_target(check \${CMAKE_COMMAND} -E env CTEST_OUTPUT_ON_FAILURE=1 BOOST_TEST_LOG_LEVEL=all
        \${CMAKE_CTEST_COMMAND} -C $<CONFIG> --verbose
        WORKING_DIRECTORY \${CMAKE_BINARY_DIR})

enable_testing()

add_test(${primary_class_name}  ${primary_class_name}Test)
EOF

echo "Filling ${primary_class_name}.cpp"
cat > $project_directory_name/src/$primary_class_name.cpp << EOF
#include "${primary_class_name}.hpp"
using namespace std;

${primary_class_name}::${primary_class_name}() {
}

${primary_class_name}::${primary_class_name}(const ${primary_class_name}& orig) {
}
string ${primary_class_name}::giveVoice()  {
	return "ItsWorking";
}
${primary_class_name}::~${primary_class_name}() {
}
EOF

echo "Filling ${primary_class_name}.hpp"
cat > $project_directory_name/include/$primary_class_name.hpp << EOF
#ifndef ${primary_class_name}_HPP
#define ${primary_class_name}_HPP

#include <string>

using namespace std;

class ${primary_class_name} {
public:
    ${primary_class_name}();
    string giveVoice();
    ${primary_class_name}(const ${primary_class_name}& orig);
    virtual ~${primary_class_name}();
private:

};

#endif
EOF

echo "Filling ${test_entry_file_name}.hpp"
cat > $test_directory_name/$test_entry_file_name << EOF
#define BOOST_AUTO_TEST_MAIN//root of all tests suites and cases
#define BOOST_TEST_DYN_LINK //use shared boost library
#include <boost/test/unit_test.hpp>

using namespace boost::unit_test;

struct MyConfig {

    MyConfig() {
        //      unit_test_log.set_format( output_format.XML ); 
        //      unit_test_log.set_threshold_level( log_level::all );
        //      expected_failures(2);
        //      timeout(1);
        //      tolerance(0.0001);
    }

    ~MyConfig() {
    }
};

BOOST_GLOBAL_FIXTURE(MyConfig);
EOF

echo "Filling ${test_file_name}.cpp"
cat > $test_directory_name/$test_file_name << EOF
#include <boost/test/unit_test.hpp>

#include "${primary_class_name}.hpp"

BOOST_AUTO_TEST_CASE(${primary_class_name}ConstructorTest) {
	${primary_class_name}* mytest = new ${primary_class_name}();
	BOOST_CHECK_EQUAL(mytest->giveVoice(), "ItsWorking");
}
EOF

echo "Filling ${project_entry_file_name}.cpp"
cat > $project_directory_name/$project_entry_file_name << EOF
int main() {
	return 0;
}
EOF

cd $build_directory_name
cmake ..
